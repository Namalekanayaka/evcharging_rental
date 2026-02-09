import db from "../../config/database.js";

export class UserService {
  // Get user profile
  async getUserProfile(userId) {
    try {
      const user = await db.one(
        `SELECT id, email, phone, first_name, last_name, user_type, profile_image, 
                bio, average_rating, total_reviews, is_verified, created_at
         FROM users WHERE id = $1`,
        [userId],
      );
      return user;
    } catch (error) {
      throw error;
    }
  }

  // Update user profile
  async updateUserProfile(userId, data) {
    try {
      const { firstName, lastName, bio, profileImage } = data;

      const user = await db.one(
        `UPDATE users 
         SET first_name = COALESCE($1, first_name),
             last_name = COALESCE($2, last_name),
             bio = COALESCE($3, bio),
             profile_image = COALESCE($4, profile_image),
             updated_at = NOW()
         WHERE id = $5
         RETURNING id, email, phone, first_name, last_name, user_type, profile_image, bio`,
        [firstName, lastName, bio, profileImage, userId],
      );

      return user;
    } catch (error) {
      throw error;
    }
  }

  // Get user statistics
  async getUserStats(userId) {
    try {
      const stats = await db.one(
        `SELECT 
           (SELECT COUNT(*) FROM bookings WHERE user_id = $1) as total_bookings,
           (SELECT COUNT(*) FROM bookings WHERE user_id = $1 AND status = 'completed') as completed_bookings,
           (SELECT COUNT(*) FROM chargers WHERE owner_id = $1) as chargers_owned,
           (SELECT AVG(rating) FROM reviews WHERE reviewer_id = $1) as average_rating,
           (SELECT COUNT(*) FROM reviews WHERE reviewer_id = $1) as total_reviews_given,
           (SELECT SUM(amount) FROM wallet_transactions WHERE user_id = $1 AND type = 'credit') as total_spent
         FROM users WHERE id = $1`,
        [userId],
      );
      return stats;
    } catch (error) {
      throw error;
    }
  }

  // Search users (for admin)
  async searchUsers(filters) {
    try {
      let query = "SELECT * FROM users WHERE 1=1";
      const params = [];

      if (filters.email) {
        params.push(`%${filters.email}%`);
        query += ` AND email ILIKE $${params.length}`;
      }

      if (filters.userType) {
        params.push(filters.userType);
        query += ` AND user_type = $${params.length}`;
      }

      if (filters.isVerified !== undefined) {
        params.push(filters.isVerified);
        query += ` AND is_verified = $${params.length}`;
      }

      query += " ORDER BY created_at DESC LIMIT 50";

      const users = await db.query(query, params);
      return users;
    } catch (error) {
      throw error;
    }
  }

  // Change password
  async changePassword(userId, oldPassword, newPassword) {
    try {
      const { hashPassword, comparePassword } =
        await import("../../utils/helpers.js");

      const user = await db.one("SELECT password FROM users WHERE id = $1", [
        userId,
      ]);

      const isPasswordValid = await comparePassword(oldPassword, user.password);
      if (!isPasswordValid) {
        throw new Error("Current password is incorrect");
      }

      const hashedPassword = await hashPassword(newPassword);

      await db.query(
        "UPDATE users SET password = $1, updated_at = NOW() WHERE id = $2",
        [hashedPassword, userId],
      );

      return { message: "Password changed successfully" };
    } catch (error) {
      throw error;
    }
  }

  // Get user bookings
  async getUserBookings(userId, limit = 20, offset = 0) {
    try {
      const bookings = await db.query(
        `SELECT b.*, c.name as charger_name, c.address
         FROM bookings b
         JOIN chargers c ON b.charger_id = c.id
         WHERE b.user_id = $1
         ORDER BY b.created_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset],
      );
      return bookings;
    } catch (error) {
      throw error;
    }
  }
}

export default new UserService();
