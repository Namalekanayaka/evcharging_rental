/**
 * Review Service
 * Manages charger reviews, user reviews, ratings, and trust scores
 */

const db = require('../database/connection');

class ReviewService {
  /**
   * Submit a review for a charger
   */
  async submitReview(userId, chargerId, reviewData) {
    const { rating, title, reviewText, cleanliness, safety, supportRating } = reviewData;

    if (!rating || rating < 1 || rating > 5) throw new Error('Rating must be between 1 and 5');
    if (!title || !reviewText) throw new Error('Title and review text are required');

    const result = await db.query(
      `INSERT INTO charger_reviews 
       (charger_id, user_id, rating, title, review_text, cleanliness, safety, support_rating, is_approved)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, true)
       RETURNING *`,
      [chargerId, userId, rating, title, reviewText, cleanliness || rating, safety || rating, supportRating || rating]
    );

    await this.updateChargerAverageRating(chargerId);
    return result.rows[0];
  }

  /**
   * Get all reviews for a charger
   */
  async getChargerReviews(chargerId, limit = 10, offset = 0) {
    const result = await db.query(
      `SELECT r.*, u.first_name, u.last_name, u.profile_picture
       FROM charger_reviews r
       JOIN users u ON r.user_id = u.id
       WHERE r.charger_id = $1 AND r.is_approved = true
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [chargerId, limit, offset]
    );
    return result.rows;
  }

  /**
   * Get review count for a charger
   */
  async getReviewCount(chargerId) {
    const result = await db.query(
      'SELECT COUNT(*) as count FROM charger_reviews WHERE charger_id = $1 AND is_approved = true',
      [chargerId]
    );
    return parseInt(result.rows[0].count);
  }

  /**
   * Update charger's average rating and review statistics
   */
  async updateChargerAverageRating(chargerId) {
    const result = await db.query(
      `SELECT 
         AVG(rating) as avg_rating,
         COUNT(*) as total_reviews,
         AVG(cleanliness) as avg_cleanliness,
         AVG(safety) as avg_safety,
         AVG(support_rating) as avg_support
       FROM charger_reviews
       WHERE charger_id = $1 AND is_approved = true`,
      [chargerId]
    );

    const stats = result.rows[0];

    await db.query(
      `UPDATE chargers 
       SET average_rating = $1, total_reviews = $2
       WHERE id = $3`,
      [stats.avg_rating ? Math.round(stats.avg_rating * 10) / 10 : null, stats.total_reviews, chargerId]
    );

    return stats;
  }

  /**
   * Get user's trust score (based on reviews they left)
   */
  async getUserTrustScore(userId) {
    const result = await db.query(
      `SELECT 
         COUNT(*) as total_reviews,
         AVG(CASE WHEN is_helpful_count > is_unhelpful_count THEN 1 ELSE 0 END) * 100 as helpfulness_rating,
         COUNT(CASE WHEN is_approved = false THEN 1 END) as rejected_reviews
       FROM charger_reviews
       WHERE user_id = $1`,
      [userId]
    );

    const stats = result.rows[0];

    // Calculate trust score (0-100)
    let trustScore = 100;
    if (stats.rejected_reviews > 0) trustScore -= (stats.rejected_reviews * 5);
    if (stats.helpfulness_rating) trustScore = (trustScore + stats.helpfulness_rating) / 2;

    return {
      trustScore: Math.max(0, trustScore),
      totalReviews: parseInt(stats.total_reviews),
      rejectedReviews: parseInt(stats.rejected_reviews),
      helpfulnessRating: stats.helpfulness_rating ? Math.round(stats.helpfulness_rating) : 0
    };
  }

  /**
   * Mark review as helpful
   */
  async markReviewHelpful(reviewId) {
    const result = await db.query(
      `UPDATE charger_reviews 
       SET is_helpful_count = is_helpful_count + 1
       WHERE id = $1
       RETURNING *`,
      [reviewId]
    );
    return result.rows[0];
  }

  /**
   * Mark review as unhelpful
   */
  async markReviewUnhelpful(reviewId) {
    const result = await db.query(
      `UPDATE charger_reviews 
       SET is_unhelpful_count = is_unhelpful_count + 1
       WHERE id = $1
       RETURNING *`,
      [reviewId]
    );
    return result.rows[0];
  }

  /**
   * Get reviews pending moderation (admin)
   */
  async getPendingReviews(limit = 20, offset = 0) {
    const result = await db.query(
      `SELECT r.*, c.name as charger_name, u.first_name, u.last_name
       FROM charger_reviews r
       JOIN chargers c ON r.charger_id = c.id
       JOIN users u ON r.user_id = u.id
       WHERE r.is_approved = false
       ORDER BY r.created_at ASC
       LIMIT $1 OFFSET $2`,
      [limit, offset]
    );
    return result.rows;
  }

  /**
   * Approve or reject a review (admin)
   */
  async moderateReview(reviewId, approved, reason = null) {
    const result = await db.query(
      `UPDATE charger_reviews 
       SET is_approved = $1, moderation_reason = $2, moderated_at = NOW()
       WHERE id = $3
       RETURNING *`,
      [approved, reason, reviewId]
    );

    if (approved) {
      await this.updateChargerAverageRating(result.rows[0].charger_id);
    }

    return result.rows[0];
  }

  /**
   * Get user's reviews
   */
  async getUserReviews(userId, limit = 20, offset = 0) {
    const result = await db.query(
      `SELECT r.*, c.name as charger_name, c.id as charger_id
       FROM charger_reviews r
       JOIN chargers c ON r.charger_id = c.id
       WHERE r.user_id = $1
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    return result.rows;
  }

  /**
   * Delete review
   */
  async deleteReview(reviewId) {
    const review = await db.query(
      'SELECT charger_id FROM charger_reviews WHERE id = $1',
      [reviewId]
    );

    await db.query('DELETE FROM charger_reviews WHERE id = $1', [reviewId]);

    if (review.rows[0]) {
      await this.updateChargerAverageRating(review.rows[0].charger_id);
    }

    return { success: true };
  }

  /**
   * Get review statistics for charger
   */
  async getReviewStatistics(chargerId) {
    const result = await db.query(
      `SELECT 
         COUNT(*) as total_reviews,
         AVG(rating) as average_rating,
         AVG(cleanliness) as average_cleanliness,
         AVG(safety) as average_safety,
         AVG(support_rating) as average_support,
         COUNT(CASE WHEN rating >= 4 THEN 1 END) as positive_reviews,
         COUNT(CASE WHEN rating < 4 AND rating > 2 THEN 1 END) as neutral_reviews,
         COUNT(CASE WHEN rating <= 2 THEN 1 END) as negative_reviews,
         COUNT(DISTINCT user_id) as unique_reviewers
       FROM charger_reviews
       WHERE charger_id = $1 AND is_approved = true`,
      [chargerId]
    );

    return result.rows[0];
  }

  /**
   * Get owner's average rating across all chargers
   */
  async getOwnerAverageRating(ownerId) {
    const result = await db.query(
      `SELECT 
         AVG(c.average_rating) as avg_rating,
         COUNT(DISTINCT c.id) as charger_count,
         SUM(c.total_reviews) as total_reviews
       FROM chargers c
       WHERE c.owner_id = $1`,
      [ownerId]
    );

    return result.rows[0];
  }
}

module.exports = new ReviewService();
