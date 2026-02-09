import db from "../../config/database.js";

export class AdminService {
  // Get dashboard stats
  async getDashboardStats() {
    try {
      const stats = await db.one(
        `SELECT 
           (SELECT COUNT(*) FROM users) as total_users,
           (SELECT COUNT(*) FROM users WHERE user_type = 'driver') as total_drivers,
           (SELECT COUNT(*) FROM users WHERE user_type = 'charger_owner') as total_owners,
           (SELECT COUNT(*) FROM chargers WHERE status = 'active') as active_chargers,
           (SELECT COUNT(*) FROM bookings WHERE status = 'completed') as completed_bookings,
           (SELECT COUNT(*) FROM bookings WHERE status = 'pending') as pending_bookings,
           (SELECT SUM(CAST(total_amount AS DECIMAL)) FROM bookings WHERE status = 'completed') as total_revenue,
           (SELECT AVG(rating) FROM reviews) as avg_rating
         FROM users WHERE user_type = 'admin' LIMIT 1`,
      );
      return stats;
    } catch (error) {
      throw error;
    }
  }

  // Get all users
  async getAllUsers(limit = 50, offset = 0) {
    try {
      const users = await db.query(
        `SELECT id, email, phone, first_name, last_name, user_type, is_verified, created_at 
         FROM users 
         ORDER BY created_at DESC 
         LIMIT $1 OFFSET $2`,
        [limit, offset],
      );
      return users;
    } catch (error) {
      throw error;
    }
  }

  // Get all chargers
  async getAllChargers(limit = 50, offset = 0) {
    try {
      const chargers = await db.query(
        `SELECT c.*, u.first_name, u.last_name, u.email,
                (SELECT AVG(rating) FROM reviews WHERE charger_id = c.id) as avg_rating
         FROM chargers c
         JOIN users u ON c.owner_id = u.id
         ORDER BY c.created_at DESC
         LIMIT $1 OFFSET $2`,
        [limit, offset],
      );
      return chargers;
    } catch (error) {
      throw error;
    }
  }

  // Get all bookings
  async getAllBookings(limit = 50, offset = 0, filters = {}) {
    try {
      let query = `SELECT b.*, c.name as charger_name, u.first_name, u.last_name, u.email
                   FROM bookings b
                   JOIN chargers c ON b.charger_id = c.id
                   JOIN users u ON b.user_id = u.id
                   WHERE 1=1`;
      const params = [];

      if (filters.status) {
        params.push(filters.status);
        query += ` AND b.status = $${params.length}`;
      }

      query +=
        " ORDER BY b.created_at DESC LIMIT $" +
        (params.length + 1) +
        " OFFSET $" +
        (params.length + 2);
      params.push(limit, offset);

      const bookings = await db.query(query, params);
      return bookings;
    } catch (error) {
      throw error;
    }
  }

  // Suspend user
  async suspendUser(userId, reason) {
    try {
      const user = await db.one(
        `UPDATE users SET status = 'suspended', suspension_reason = $1, updated_at = NOW()
         WHERE id = $2
         RETURNING *`,
        [reason, userId],
      );
      return user;
    } catch (error) {
      throw error;
    }
  }

  // Activate user
  async activateUser(userId) {
    try {
      const user = await db.one(
        `UPDATE users SET status = 'active', updated_at = NOW()
         WHERE id = $1
         RETURNING *`,
        [userId],
      );
      return user;
    } catch (error) {
      throw error;
    }
  }

  // Disable charger
  async disableCharger(chargerId, reason) {
    try {
      const charger = await db.one(
        `UPDATE chargers SET status = 'disabled', disabled_reason = $1, updated_at = NOW()
         WHERE id = $2
         RETURNING *`,
        [reason, chargerId],
      );
      return charger;
    } catch (error) {
      throw error;
    }
  }

  // Enable charger
  async enableCharger(chargerId) {
    try {
      const charger = await db.one(
        `UPDATE chargers SET status = 'active', updated_at = NOW()
         WHERE id = $1
         RETURNING *`,
        [chargerId],
      );
      return charger;
    } catch (error) {
      throw error;
    }
  }

  // Get revenue timeline
  async getRevenueTimeline(days = 30) {
    try {
      const revenue = await db.query(
        `SELECT DATE(created_at) as date, SUM(CAST(total_amount AS DECIMAL)) as amount
         FROM bookings
         WHERE status = 'completed' AND created_at >= NOW() - INTERVAL '${days} days'
         GROUP BY DATE(created_at)
         ORDER BY date DESC`,
      );
      return revenue;
    } catch (error) {
      throw error;
    }
  }

  // Get reports
  async getReports() {
    try {
      const reports = await db.query(
        "SELECT * FROM admin_reports ORDER BY created_at DESC LIMIT 100",
      );
      return reports;
    } catch (error) {
      throw error;
    }
  }
}

export default new AdminService();
