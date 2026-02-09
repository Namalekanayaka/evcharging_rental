import db from "../../config/database.js";

class BookingService {
  /**
   * Create a new booking with validation
   * @param {number} userId - User ID
   * @param {number} chargerId - Charger ID
   * @param {Object} bookingData - Booking details
   * @returns {Promise<Object>} Created booking
   */
  async createBooking(userId, chargerId, bookingData) {
    const {
      startTime,
      endTime,
      duration,
      notes,
      isEmergency = false,
      estimatedKwh,
    } = bookingData;

    const client = await db.connect();

    try {
      await client.query("BEGIN");

      // Check charger exists and is active
      const chargerCheck = await client.query(
        "SELECT * FROM chargers WHERE id = $1 AND status = 'active'",
        [chargerId],
      );

      if (chargerCheck.rows.length === 0) {
        throw new Error("Charger not found or inactive");
      }

      const charger = chargerCheck.rows[0];

      // Check for double booking (prevent overlapping bookings)
      const overlapCheck = await client.query(
        `SELECT * FROM bookings 
         WHERE charger_id = $1 
         AND status IN ('active', 'reserved', 'pending')
         AND (
           (start_time < $3 AND end_time > $2)
           OR (start_time = $2)
         )`,
        [chargerId, startTime, endTime],
      );

      if (overlapCheck.rows.length > 0) {
        throw new Error("Time slot already booked");
      }

      // Check available ports
      const availableCheck = await client.query(
        `SELECT COUNT(*) as active_count FROM bookings
         WHERE charger_id = $1 
         AND status IN ('active', 'reserved')
         AND start_time < $3 AND end_time > $2`,
        [chargerId, startTime, endTime],
      );

      const activeCount = parseInt(availableCheck.rows[0].active_count);
      if (activeCount >= charger.total_ports) {
        throw new Error("No available ports");
      }

      // Create booking
      const bookingResult = await client.query(
        `INSERT INTO bookings (
          user_id, charger_id, start_time, end_time, duration, 
          status, notes, is_emergency, estimated_kwh, created_at
        ) VALUES ($1, $2, $3, $4, $5, 'reserved', $6, $7, $8, NOW())
        RETURNING *`,
        [userId, chargerId, startTime, endTime, duration, notes, isEmergency, estimatedKwh],
      );

      await client.query("COMMIT");
      return bookingResult.rows[0];
    } catch (error) {
      await client.query("ROLLBACK");
      throw new Error(`Booking creation failed: ${error.message}`);
    } finally {
      client.release();
    }
  }

  /**
   * Emergency instant booking (priority)
   * @param {number} userId - User ID
   * @param {number} chargerId - Charger ID
   * @returns {Promise<Object>} Emergency booking
   */
  async createEmergencyBooking(userId, chargerId) {
    try {
      // Check charger availability
      const availability = await db.query(
        `SELECT (total_ports - COALESCE(
          (SELECT COUNT(*) FROM bookings 
           WHERE charger_id = $1 AND status IN ('active', 'reserved')), 0
        )) as available_ports, total_ports FROM chargers WHERE id = $1`,
        [chargerId],
      );

      if (availability.rows.length === 0) {
        throw new Error("Charger not found");
      }

      const { available_ports, total_ports } = availability.rows[0];

      if (available_ports <= 0) {
        // Preempt lower-priority bookings
        await this._preemptLowPriorityBookings(chargerId, 1);
      }

      const now = new Date();
      const endTime = new Date(now.getTime() + 8 * 60 * 60 * 1000); // 8 hours

      const result = await db.query(
        `INSERT INTO bookings (
          user_id, charger_id, start_time, end_time, duration,
          status, is_emergency, created_at
        ) VALUES ($1, $2, $3, $4, $5, 'active', true, NOW())
        RETURNING *`,
        [userId, chargerId, now, endTime, 480],
      );

      return result.rows[0];
    } catch (error) {
      throw new Error(`Emergency booking failed: ${error.message}`);
    }
  }

  // Original methods (kept for compatibility)
  async getBooking(bookingId) {
    try {
      const booking = await db.query(
        `SELECT b.*, c.location_name as charger_name, c.address, 
                u.name, u.email
         FROM bookings b
         JOIN chargers c ON b.charger_id = c.id
         JOIN users u ON b.user_id = u.id
         WHERE b.id = $1`,
        [bookingId],
      );
      return booking.rows[0];
    } catch (error) {
      throw error;
    }
  }

  async getBookings(userId, filters = {}) {
    try {
      let query = `SELECT b.*, c.location_name as charger_name, c.address
                   FROM bookings b
                   JOIN chargers c ON b.charger_id = c.id
                   WHERE b.user_id = $1`;
      const params = [userId];

      if (filters.status) {
        params.push(filters.status);
        query += ` AND b.status = $${params.length}`;
      }

      query += " ORDER BY b.start_time DESC LIMIT 50";

      const bookings = await db.query(query, params);
      return bookings.rows;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Cancel a booking with refund support
   * @param {number} bookingId - Booking ID
   * @param {string} cancelReason - Cancellation reason
   * @returns {Promise<Object>} Cancelled booking
   */
  async cancelBooking(bookingId, cancelReason) {
    try {
      // Check booking status
      const bookingCheck = await db.query(
        "SELECT * FROM bookings WHERE id = $1",
        [bookingId],
      );

      if (bookingCheck.rows.length === 0) {
        throw new Error("Booking not found");
      }

      const booking = bookingCheck.rows[0];

      if (!["reserved", "pending", "active"].includes(booking.status)) {
        throw new Error("Cannot cancel completed or already cancelled booking");
      }

      // Calculate refund if applicable
      let refundAmount = 0;
      if (booking.status === "reserved" || booking.status === "pending") {
        const hoursDiff = Math.abs(
          new Date(booking.start_time) - new Date(),
        ) / 36e5;
        // Full refund if cancelled 2 hours before start
        if (hoursDiff >= 2) {
          refundAmount = booking.estimated_cost || 0;
        } else if (hoursDiff >= 1) {
          refundAmount = (booking.estimated_cost || 0) * 0.5; // 50% refund
        }
      }

      // Update booking
      const result = await db.query(
        `UPDATE bookings 
         SET status = 'cancelled', cancellation_reason = $2, 
             refund_amount = $3, cancelled_at = NOW()
         WHERE id = $1
         RETURNING *`,
        [bookingId, cancelReason, refundAmount],
      );

      // Process refund if any
      if (refundAmount > 0) {
        await db.query(
          `UPDATE wallets 
           SET balance = balance + $1 
           WHERE user_id = $2`,
          [refundAmount, booking.user_id],
        );
      }

      return result.rows[0];
    } catch (error) {
      throw new Error(`Cancel booking failed: ${error.message}`);
    }
  }

  /**
   * Reschedule a booking
   * @param {number} bookingId - Booking ID
   * @param {Object} newTiming - New start and end times
   * @returns {Promise<Object>} Rescheduled booking
   */
  async rescheduleBooking(bookingId, newTiming) {
    const { newStartTime, newEndTime } = newTiming;

    const client = await db.connect();

    try {
      await client.query("BEGIN");

      // Get existing booking
      const bookingCheck = await client.query(
        "SELECT * FROM bookings WHERE id = $1",
        [bookingId],
      );

      if (bookingCheck.rows.length === 0) {
        throw new Error("Booking not found");
      }

      const booking = bookingCheck.rows[0];

      if (booking.status === "completed" || booking.status === "cancelled") {
        throw new Error("Cannot reschedule completed or cancelled booking");
      }

      // Check for conflicts with new timing
      const conflictCheck = await client.query(
        `SELECT * FROM bookings 
         WHERE charger_id = $1 
         AND id != $2
         AND status IN ('active', 'reserved', 'pending')
         AND (start_time < $4 AND end_time > $3)`,
        [booking.charger_id, bookingId, newStartTime, newEndTime],
      );

      if (conflictCheck.rows.length > 0) {
        throw new Error("New time slot conflicts with existing booking");
      }

      // Update booking
      const newDuration =
        (new Date(newEndTime) - new Date(newStartTime)) / 60000; // in minutes

      const result = await client.query(
        `UPDATE bookings 
         SET start_time = $2, end_time = $3, duration = $4,
             rescheduled_at = NOW(), reschedule_count = reschedule_count + 1
         WHERE id = $1
         RETURNING *`,
        [bookingId, newStartTime, newEndTime, newDuration],
      );

      await client.query("COMMIT");
      return result.rows[0];
    } catch (error) {
      await client.query("ROLLBACK");
      throw new Error(`Reschedule failed: ${error.message}`);
    } finally {
      client.release();
    }
  }

  async completeBooking(bookingId) {
    try {
      const booking = await db.query(
        `UPDATE bookings SET status = 'completed', completed_at = NOW()
         WHERE id = $1 AND status IN ('active', 'in-progress')
         RETURNING *`,
        [bookingId],
      );
      return booking.rows[0];
    } catch (error) {
      throw error;
    }
  }

  async getBookingHistory(userId, limit = 20, offset = 0) {
    try {
      const bookings = await db.query(
        `SELECT b.*, c.location_name as charger_name, c.address
         FROM bookings b
         JOIN chargers c ON b.charger_id = c.id
         WHERE b.user_id = $1 AND b.status = 'completed'
         ORDER BY b.completed_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset],
      );
      return bookings.rows;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Auto-complete and expire old bookings
   * @returns {Promise<Object>} Count of updated bookings
   */
  async autoCompleteExpiredBookings() {
    try {
      const result = await db.query(
        `UPDATE bookings 
         SET status = 'completed', completed_at = NOW()
         WHERE status IN ('active', 'reserved')
         AND end_time < NOW()
         AND completed_at IS NULL`,
      );

      return { updated: result.rowCount };
    } catch (error) {
      throw new Error(`Auto-complete failed: ${error.message}`);
    }
  }

  /**
   * Auto-expire unconfirmed reservations
   * @returns {Promise<Object>} Count of expired bookings
   */
  async autoExpireUnconfirmedBookings() {
    try {
      const result = await db.query(
        `UPDATE bookings 
         SET status = 'expired'
         WHERE status = 'pending'
         AND created_at < NOW() - INTERVAL '10 minutes'`,
      );

      return { expired: result.rowCount };
    } catch (error) {
      throw new Error(`Auto-expire failed: ${error.message}`);
    }
  }

  /**
   * Check availability for a time slot
   * @param {number} chargerId - Charger ID
   * @param {Date} startTime - Start time
   * @param {Date} endTime - End time
   * @returns {Promise<Object>} Availability info
   */
  async checkSlotAvailability(chargerId, startTime, endTime) {
    try {
      const result = await db.query(
        `SELECT 
          c.total_ports,
          (c.total_ports - COALESCE(
            (SELECT COUNT(*) FROM bookings 
             WHERE charger_id = $1 
             AND status IN ('active', 'reserved')
             AND start_time < $3 AND end_time > $2), 0
          )) as available_ports,
          COALESCE(
            (SELECT COUNT(*) FROM bookings 
             WHERE charger_id = $1 
             AND status IN ('active', 'reserved')
             AND start_time < $3 AND end_time > $2), 0
          ) as occupied_ports
         FROM chargers c
         WHERE c.id = $1`,
        [chargerId, startTime, endTime],
      );

      if (result.rows.length === 0) {
        throw new Error("Charger not found");
      }

      const data = result.rows[0];
      return {
        isAvailable: parseInt(data.available_ports) > 0,
        availablePorts: parseInt(data.available_ports),
        occupiedPorts: parseInt(data.occupied_ports),
        totalPorts: parseInt(data.total_ports),
      };
    } catch (error) {
      throw new Error(`Availability check failed: ${error.message}`);
    }
  }

  /**
   * Private method to preempt low-priority bookings
   * @private
   */
  async _preemptLowPriorityBookings(chargerId, count) {
    try {
      // Find and cancel non-emergency bookings with lowest priority
      const toCancel = await db.query(
        `SELECT id FROM bookings 
         WHERE charger_id = $1 
         AND status = 'reserved'
         AND is_emergency = false
         ORDER BY created_at ASC
         LIMIT $2`,
        [chargerId, count],
      );

      for (const booking of toCancel.rows) {
        await this.cancelBooking(booking.id, "Preempted for emergency booking");
      }

      return toCancel.rowCount;
    } catch (error) {
      console.error("Preemption failed:", error);
    }
  }
}

export default new BookingService();
