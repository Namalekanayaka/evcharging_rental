import db from "../../config/database.js";

export class ReviewService {
  // Create review
  async createReview(userId, data) {
    try {
      const { chargerId, rating, comment, bookingId } = data;

      if (rating < 1 || rating > 5) {
        throw new Error("Rating must be between 1 and 5");
      }

      // Check if user completed the booking
      const booking = await db.oneOrNone(
        "SELECT * FROM bookings WHERE id = $1 AND user_id = $2 AND status = $3",
        [bookingId, userId, "completed"],
      );

      if (!booking) {
        throw new Error("Invalid booking or booking not completed");
      }

      // Check if review already exists
      const existingReview = await db.oneOrNone(
        "SELECT id FROM reviews WHERE booking_id = $1",
        [bookingId],
      );

      if (existingReview) {
        throw new Error("Review already exists for this booking");
      }

      const review = await db.one(
        `INSERT INTO reviews (user_id, charger_id, booking_id, rating, comment)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [userId, chargerId, bookingId, rating, comment],
      );

      // Update charger average rating
      await db.query(
        `UPDATE chargers SET average_rating = 
         (SELECT AVG(rating) FROM reviews WHERE charger_id = $1)
         WHERE id = $1`,
        [chargerId],
      );

      return review;
    } catch (error) {
      throw error;
    }
  }

  // Get charger reviews
  async getChargerReviews(chargerId, limit = 20, offset = 0) {
    try {
      const reviews = await db.query(
        `SELECT r.*, u.first_name, u.last_name, u.profile_image
         FROM reviews r
         JOIN users u ON r.user_id = u.id
         WHERE r.charger_id = $1
         ORDER BY r.created_at DESC
         LIMIT $2 OFFSET $3`,
        [chargerId, limit, offset],
      );
      return reviews;
    } catch (error) {
      throw error;
    }
  }

  // Get user reviews
  async getUserReviews(userId, limit = 20, offset = 0) {
    try {
      const reviews = await db.query(
        `SELECT r.*, c.name as charger_name, c.address
         FROM reviews r
         JOIN chargers c ON r.charger_id = c.id
         WHERE r.user_id = $1
         ORDER BY r.created_at DESC
         LIMIT $2 OFFSET $3`,
        [userId, limit, offset],
      );
      return reviews;
    } catch (error) {
      throw error;
    }
  }

  // Get review statistics
  async getChargerReviewStats(chargerId) {
    try {
      const stats = await db.one(
        `SELECT 
           COUNT(*) as total_reviews,
           ROUND(AVG(rating)::numeric, 2) as average_rating,
           SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star,
           SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star,
           SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star,
           SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star,
           SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star
         FROM reviews WHERE charger_id = $1`,
        [chargerId],
      );
      return stats;
    } catch (error) {
      throw error;
    }
  }

  // Update review
  async updateReview(reviewId, userId, data) {
    try {
      const { rating, comment } = data;

      const review = await db.one(
        `UPDATE reviews SET rating = $1, comment = $2, updated_at = NOW()
         WHERE id = $3 AND user_id = $4
         RETURNING *`,
        [rating, comment, reviewId, userId],
      );

      if (!review) {
        throw new Error("Review not found or unauthorized");
      }

      return review;
    } catch (error) {
      throw error;
    }
  }

  // Delete review
  async deleteReview(reviewId, userId) {
    try {
      const result = await db.result(
        "DELETE FROM reviews WHERE id = $1 AND user_id = $2",
        [reviewId, userId],
      );

      if (result.rowCount === 0) {
        throw new Error("Review not found");
      }

      return { message: "Review deleted successfully" };
    } catch (error) {
      throw error;
    }
  }
}

export default new ReviewService();
