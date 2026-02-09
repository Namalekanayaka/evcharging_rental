import db from "../../config/database.js";

class SessionService {
  /**
   * Start a charging session
   * @param {number} chargerId - Charger ID
   * @param {number} bookingId - Booking ID
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Created session
   */
  async startSession(chargerId, bookingId, userId) {
    try {
      const session = await db.query(
        `INSERT INTO charging_sessions (
          charger_id, booking_id, user_id, start_time, status, 
          initial_battery, initial_kwh_reading
        ) VALUES ($1, $2, $3, NOW(), 'active', 0, 0)
        RETURNING *`,
        [chargerId, bookingId, userId],
      );

      // Update booking status
      await db.query(
        "UPDATE bookings SET status = 'active' WHERE id = $1",
        [bookingId],
      );

      return session.rows[0];
    } catch (error) {
      throw new Error(`Failed to start session: ${error.message}`);
    }
  }

  /**
   * Update session progress (from IoT device)
   * @param {number} sessionId - Session ID
   * @param {Object} data - Session data
   * @returns {Promise<Object>} Updated session
   */
  async updateSessionProgress(sessionId, data) {
    const {
      currentKwh,
      currentBattery,
      chargingPower,
      voltage,
      amperage,
      temperature,
    } = data;

    try {
      const session = await db.query(
        "SELECT * FROM charging_sessions WHERE id = $1",
        [sessionId],
      );

      if (session.rows.length === 0) {
        throw new Error("Session not found");
      }

      const currentSession = session.rows[0];

      // Calculate delta energy if initial reading exists
      const energyDelta = currentKwh - (currentSession.initial_kwh_reading || 0);
      const duration = Math.abs(new Date() - new Date(currentSession.start_time)) / 60000; // in minutes

      // Update session
      const updated = await db.query(
        `UPDATE charging_sessions 
         SET current_kwh = $2, current_battery = $3, charging_power = $4,
             voltage = $5, amperage = $6, temperature = $7,
             energy_delivered = $8, updated_at = NOW()
         WHERE id = $1
         RETURNING *`,
        [
          sessionId,
          currentKwh,
          currentBattery,
          chargingPower,
          voltage,
          amperage,
          temperature,
          energyDelta,
        ],
      );

      return updated.rows[0];
    } catch (error) {
      throw new Error(`Failed to update session: ${error.message}`);
    }
  }

  /**
   * Stop charging session and calculate cost
   * @param {number} sessionId - Session ID
   * @returns {Promise<Object>} Completed session with billing info
   */
  async stopSession(sessionId) {
    const client = await db.connect();

    try {
      await client.query("BEGIN");

      // Get session details
      const sessionCheck = await client.query(
        "SELECT * FROM charging_sessions WHERE id = $1",
        [sessionId],
      );

      if (sessionCheck.rows.length === 0) {
        throw new Error("Session not found");
      }

      const session = sessionCheck.rows[0];

      if (session.status === "completed") {
        throw new Error("Session already completed");
      }

      // Get charger pricing
      const charger = await client.query(
        "SELECT * FROM chargers WHERE id = $1",
        [session.charger_id],
      );

      const chargerData = charger.rows[0];

      // Calculate duration in hours
      const durationMs = new Date() - new Date(session.start_time);
      const durationHours = durationMs / (1000 * 60 * 60);
      const durationMinutes = Math.round(durationMs / 60000);

      // Calculate energy delivered (kWh)
      const energyDelivered = session.energy_delivered || 0;

      // Calculate cost based on charger pricing
      // Assuming charger has price_per_kwh and optional hourly_rate
      let totalCost = 0;
      if (chargerData.price_per_kwh) {
        totalCost += energyDelivered * chargerData.price_per_kwh;
      }
      if (chargerData.hourly_rate && durationHours > 0) {
        totalCost += durationHours * chargerData.hourly_rate;
      }

      // Apply peak pricing if during peak hours
      const hour = new Date().getHours();
      const isPeakHour = hour >= 18 && hour <= 21; // 6 PM - 9 PM
      if (isPeakHour && chargerData.peak_multiplier) {
        totalCost *= chargerData.peak_multiplier;
      }

      // Update session with completion details
      const updated = await client.query(
        `UPDATE charging_sessions 
         SET status = 'completed', end_time = NOW(),
             duration_minutes = $2, energy_delivered = $3,
             total_cost = $4, is_peak_hour = $5
         WHERE id = $1
         RETURNING *`,
        [sessionId, durationMinutes, energyDelivered, totalCost, isPeakHour],
      );

      const completedSession = updated.rows[0];

      // Create transaction record
      await client.query(
        `INSERT INTO transactions (
          user_id, charger_id, session_id, amount, type, status, description
        ) VALUES ($1, $2, $3, $4, 'charge', 'completed', $5)`,
        [
          session.user_id,
          session.charger_id,
          sessionId,
          totalCost,
          `Charging session: ${durationMinutes} minutes, ${energyDelivered.toFixed(2)} kWh`,
        ],
      );

      // Deduct from wallet
      await client.query(
        `UPDATE wallets SET balance = balance - $1 WHERE user_id = $2`,
        [totalCost, session.user_id],
      );

      // Update booking status
      await client.query(
        "UPDATE bookings SET status = 'completed' WHERE id = $1",
        [completedSession.booking_id],
      );

      await client.query("COMMIT");

      return {
        session: completedSession,
        billing: {
          energyDelivered,
          durationMinutes,
          durationHours: parseFloat(durationHours.toFixed(2)),
          totalCost: parseFloat(totalCost.toFixed(2)),
          isPeakHour,
          breakdown: {
            energyCost: energyDelivered * (chargerData.price_per_kwh || 0),
            hourcost: chargerData.hourly_rate ? durationHours * chargerData.hourly_rate : 0,
          },
        },
      };
    } catch (error) {
      await client.query("ROLLBACK");
      throw new Error(`Failed to stop session: ${error.message}`);
    } finally {
      client.release();
    }
  }

  /**
   * Get active session for a user
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Active session
   */
  async getActiveSession(userId) {
    try {
      const result = await db.query(
        `SELECT cs.*, c.location_name, c.power_output, c.price_per_kwh
         FROM charging_sessions cs
         JOIN chargers c ON cs.charger_id = c.id
         WHERE cs.user_id = $1 AND cs.status = 'active'
         LIMIT 1`,
        [userId],
      );

      if (result.rows.length > 0) {
        const session = result.rows[0];
        // Calculate duration so far
        const durationMs = new Date() - new Date(session.start_time);
        const durationMinutes = Math.round(durationMs / 60000);

        return {
          ...session,
          durationMinutes,
          estimatedCost: session.current_kwh * session.price_per_kwh,
        };
      }

      return null;
    } catch (error) {
      throw new Error(`Failed to get active session: ${error.message}`);
    }
  }

  /**
   * Get session history for a user
   * @param {number} userId - User ID
   * @param {Object} filters - Filter options
   * @returns {Promise<Array>} Session history
   */
  async getSessionHistory(userId, filters = {}) {
    const {
      limit = 20,
      offset = 0,
      startDate = null,
      endDate = null,
      minCost = null,
      maxCost = null,
    } = filters;

    try {
      let query = `
        SELECT cs.*, c.location_name, c.charger_type
        FROM charging_sessions cs
        JOIN chargers c ON cs.charger_id = c.id
        WHERE cs.user_id = $1 AND cs.status = 'completed'
      `;

      const params = [userId];
      let paramIndex = 2;

      if (startDate) {
        query += ` AND cs.start_time >= $${paramIndex}`;
        params.push(startDate);
        paramIndex++;
      }

      if (endDate) {
        query += ` AND cs.end_time <= $${paramIndex}`;
        params.push(endDate);
        paramIndex++;
      }

      if (minCost !== null) {
        query += ` AND cs.total_cost >= $${paramIndex}`;
        params.push(minCost);
        paramIndex++;
      }

      if (maxCost !== null) {
        query += ` AND cs.total_cost <= $${paramIndex}`;
        params.push(maxCost);
        paramIndex++;
      }

      query += ` ORDER BY cs.end_time DESC LIMIT $${paramIndex} OFFSET $${paramIndex + 1}`;
      params.push(limit, offset);

      const result = await db.query(query, params);
      return result.rows;
    } catch (error) {
      throw new Error(`Failed to get session history: ${error.message}`);
    }
  }

  /**
   * Get session statistics for a user
   * @param {number} userId - User ID
   * @param {Object} filters - Filter options
   * @returns {Promise<Object>} Session statistics
   */
  async getSessionStats(userId, filters = {}) {
    const { startDate = null, endDate = null } = filters;

    try {
      let query = `
        SELECT 
          COUNT(*) as total_sessions,
          SUM(energy_delivered) as total_energy_kwh,
          SUM(duration_minutes) as total_minutes,
          AVG(total_cost) as avg_cost,
          MAX(total_cost) as max_cost,
          MIN(total_cost) as min_cost,
          SUM(total_cost) as total_spent
        FROM charging_sessions
        WHERE user_id = $1 AND status = 'completed'
      `;

      const params = [userId];
      let paramIndex = 2;

      if (startDate) {
        query += ` AND start_time >= $${paramIndex}`;
        params.push(startDate);
        paramIndex++;
      }

      if (endDate) {
        query += ` AND end_time <= $${paramIndex}`;
        params.push(endDate);
        paramIndex++;
      }

      const result = await db.query(query, params);
      const stats = result.rows[0];

      return {
        totalSessions: parseInt(stats.total_sessions) || 0,
        totalEnergyKwh: parseFloat(stats.total_energy_kwh) || 0,
        totalMinutes: parseInt(stats.total_minutes) || 0,
        totalHours: (parseInt(stats.total_minutes) || 0) / 60,
        averageCost: parseFloat(stats.avg_cost) || 0,
        maxCost: parseFloat(stats.max_cost) || 0,
        minCost: parseFloat(stats.min_cost) || 0,
        totalSpent: parseFloat(stats.total_spent) || 0,
      };
    } catch (error) {
      throw new Error(`Failed to get session stats: ${error.message}`);
    }
  }

  /**
   * Get charger session statistics (for owner dashboard)
   * @param {number} chargerId - Charger ID
   * @param {Object} filters - Filter options
   * @returns {Promise<Object>} Charger statistics
   */
  async getChargerSessionStats(chargerId, filters = {}) {
    const { startDate = null, endDate = null } = filters;

    try {
      let query = `
        SELECT 
          COUNT(*) as total_sessions,
          COUNT(DISTINCT user_id) as unique_users,
          SUM(energy_delivered) as total_energy_delivered,
          SUM(duration_minutes) as total_minutes,
          SUM(total_cost) as total_revenue,
          AVG(total_cost) as avg_revenue_per_session,
          MAX(energy_delivered) as max_energy_session,
          AVG(energy_delivered) as avg_energy_per_session
        FROM charging_sessions
        WHERE charger_id = $1 AND status = 'completed'
      `;

      const params = [chargerId];
      let paramIndex = 2;

      if (startDate) {
        query += ` AND start_time >= $${paramIndex}`;
        params.push(startDate);
        paramIndex++;
      }

      if (endDate) {
        query += ` AND end_time <= $${paramIndex}`;
        params.push(endDate);
        paramIndex++;
      }

      const result = await db.query(query, params);
      const stats = result.rows[0];

      return {
        totalSessions: parseInt(stats.total_sessions) || 0,
        uniqueUsers: parseInt(stats.unique_users) || 0,
        totalEnergyDelivered: parseFloat(stats.total_energy_delivered) || 0,
        totalMinutes: parseInt(stats.total_minutes) || 0,
        totalHours: (parseInt(stats.total_minutes) || 0) / 60,
        totalRevenue: parseFloat(stats.total_revenue) || 0,
        avgRevenuePerSession: parseFloat(stats.avg_revenue_per_session) || 0,
        avgEnergyPerSession: parseFloat(stats.avg_energy_per_session) || 0,
      };
    } catch (error) {
      throw new Error(`Failed to get charger stats: ${error.message}`);
    }
  }

  /**
   * Pause a session (for temporary stop)
   * @param {number} sessionId - Session ID
   * @returns {Promise<Object>} Paused session
   */
  async pauseSession(sessionId) {
    try {
      const result = await db.query(
        `UPDATE charging_sessions 
         SET status = 'paused', paused_at = NOW()
         WHERE id = $1 AND status = 'active'
         RETURNING *`,
        [sessionId],
      );

      if (result.rows.length === 0) {
        throw new Error("Session not found or not active");
      }

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to pause session: ${error.message}`);
    }
  }

  /**
   * Resume a paused session
   * @param {number} sessionId - Session ID
   * @returns {Promise<Object>} Resumed session
   */
  async resumeSession(sessionId) {
    try {
      const session = await db.query(
        "SELECT * FROM charging_sessions WHERE id = $1",
        [sessionId],
      );

      if (session.rows.length === 0) {
        throw new Error("Session not found");
      }

      const currentSession = session.rows[0];
      const pausedDuration = Math.abs(new Date() - new Date(currentSession.paused_at)) / 1000; // in seconds

      const result = await db.query(
        `UPDATE charging_sessions 
         SET status = 'active', paused_duration = paused_duration + $2,
             resumed_at = NOW()
         WHERE id = $1
         RETURNING *`,
        [sessionId, pausedDuration],
      );

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to resume session: ${error.message}`);
    }
  }
}

export default new SessionService();
