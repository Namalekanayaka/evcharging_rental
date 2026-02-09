import db from "../../config/database.js";

export class BookingService {
  // Create booking
  async createBooking(userId, data) {
    try {
      const { chargerId, startTime, duration, totalAmount } = data;

      // Check charger availability
      const charger = await db.one("SELECT * FROM chargers WHERE id = $1", [
        chargerId,
      ]);
      if (!charger) {
        throw new Error("Charger not found");
      }

      // Check for conflicting bookings
      const conflict = await db.oneOrNone(
        `SELECT id FROM bookings 
         WHERE charger_id = $1 AND status IN ('pending', 'confirmed', 'in-progress')
         AND start_time < $2 + interval '1 hour' * $3
         AND end_time > $2`,
        [chargerId, new Date(startTime), duration],
      );

      if (conflict) {
        throw new Error("Charger is not available for the selected time");
      }

      const endTime = new Date(
        new Date(startTime).getTime() + duration * 60 * 60 * 1000,
      );

      const booking = await db.one(
        `INSERT INTO bookings 
         (user_id, charger_id, owner_id, start_time, end_time, duration, total_amount, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'pending')
         RETURNING *`,
        [
          userId,
          chargerId,
          charger.owner_id,
          startTime,
          endTime,
          duration,
          totalAmount,
        ],
      );

      return booking;
    } catch (error) {
      throw error;
    }
  }

  // Get booking
  async getBooking(bookingId) {
    try {
      const booking = await db.one(
        `SELECT b.*, c.name as charger_name, c.address, 
                u.first_name, u.last_name, u.email
         FROM bookings b
         JOIN chargers c ON b.charger_id = c.id
         JOIN users u ON b.user_id = u.id
         WHERE b.id = $1`,
        [bookingId],
      );
      return booking;
    } catch (error) {
      throw error;
    }
  }

  // Get bookings
  async getBookings(userId, filters = {}) {
    try {
      let query = `SELECT b.*, c.name as charger_name, c.address
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
      return bookings;
    } catch (error) {
      throw error;
    }
  }

  // Confirm booking
  async confirmBooking(bookingId) {
    try {
      const booking = await db.one(
        `UPDATE bookings SET status = 'confirmed', confirmed_at = NOW() 
         WHERE id = $1 AND status = 'pending'
         RETURNING *`,
        [bookingId],
      );
      return booking;
    } catch (error) {
      throw error;
    }
  }

  // Cancel booking
  async cancelBooking(bookingId, reason) {
    try {
      const booking = await db.one(
        `UPDATE bookings SET status = 'cancelled', cancellation_reason = $2, cancelled_at = NOW()
         WHERE id = $1 AND status IN ('pending', 'confirmed')
         RETURNING *`,
        [bookingId, reason],
      );
      return booking;
    } catch (error) {
      throw error;
    }
  }

  // Complete booking
  async completeBooking(bookingId) {
    try {
      const booking = await db.one(
        `UPDATE bookings SET status = 'completed', completed_at = NOW()
         WHERE id = $1 AND status = 'in-progress'
         RETURNING *`,
        [bookingId],
      );
      return booking;
    } catch (error) {
      throw error;
    }
  }

  // Get booking history
  async getBookingHistory(userId, limit = 20, offset = 0) {
    try {
      const bookings = await db.query(
        `SELECT b.*, c.name as charger_name, c.address
         FROM bookings b
         JOIN chargers c ON b.charger_id = c.id
         WHERE b.user_id = $1 AND b.status = 'completed'
         ORDER BY b.completed_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset],
      );
      return bookings;
    } catch (error) {
      throw error;
    }
  }
}

export default new BookingService();
