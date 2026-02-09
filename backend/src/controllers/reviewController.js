/**
 * Review Controller
 * Handles API requests for reviews, ratings, and trust scores
 */

const reviewService = require('../services/reviewService');
const { validateRequest, sendResponse, handleError } = require('../utils/apiHelper');

class ReviewController {
  /**
   * Submit a review for a charger
   * POST /api/reviews
   * Body: { chargerId, rating, title, reviewText, cleanliness?, safety?, supportRating? }
   */
  async submitReview(req, res) {
    try {
      validateRequest(req, 'user', 'body');
      const { chargerId, rating, title, reviewText, cleanliness, safety, supportRating } = req.body;

      if (!chargerId) throw new Error('Charger ID is required');

      const review = await reviewService.submitReview(req.user.id, chargerId, {
        rating,
        title,
        reviewText,
        cleanliness,
        safety,
        supportRating
      });

      sendResponse(res, 201, 'Review submitted successfully', review);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get reviews for a charger
   * GET /api/reviews/charger/:chargerId?limit=10&offset=0
   */
  async getChargerReviews(req, res) {
    try {
      validateRequest(req, 'params');
      const { chargerId } = req.params;
      const { limit = 10, offset = 0 } = req.query;

      if (!chargerId) throw new Error('Charger ID is required');

      const reviews = await reviewService.getChargerReviews(
        parseInt(chargerId),
        parseInt(limit),
        parseInt(offset)
      );

      const count = await reviewService.getReviewCount(parseInt(chargerId));

      sendResponse(res, 200, 'Reviews fetched successfully', {
        reviews,
        total: count
      });
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get user's reviews
   * GET /api/reviews/my-reviews?limit=20&offset=0
   */
  async getUserReviews(req, res) {
    try {
      validateRequest(req, 'user');
      const { limit = 20, offset = 0 } = req.query;

      const reviews = await reviewService.getUserReviews(
        req.user.id,
        parseInt(limit),
        parseInt(offset)
      );

      sendResponse(res, 200, 'User reviews fetched successfully', reviews);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get user's trust score
   * GET /api/reviews/trust-score
   */
  async getUserTrustScore(req, res) {
    try {
      validateRequest(req, 'user');
      const trustScore = await reviewService.getUserTrustScore(req.user.id);
      sendResponse(res, 200, 'Trust score fetched successfully', trustScore);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Mark review as helpful
   * POST /api/reviews/:reviewId/helpful
   */
  async markHelpful(req, res) {
    try {
      validateRequest(req, 'user', 'params');
      const { reviewId } = req.params;

      if (!reviewId) throw new Error('Review ID is required');

      const review = await reviewService.markReviewHelpful(parseInt(reviewId));
      sendResponse(res, 200, 'Marked as helpful', review);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Mark review as unhelpful
   * POST /api/reviews/:reviewId/unhelpful
   */
  async markUnhelpful(req, res) {
    try {
      validateRequest(req, 'user', 'params');
      const { reviewId } = req.params;

      if (!reviewId) throw new Error('Review ID is required');

      const review = await reviewService.markReviewUnhelpful(parseInt(reviewId));
      sendResponse(res, 200, 'Marked as unhelpful', review);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get pending reviews for moderation (admin)
   * GET /api/reviews/pending?limit=20&offset=0
   */
  async getPendingReviews(req, res) {
    try {
      validateRequest(req, 'user');
      // Check admin role here if needed
      const { limit = 20, offset = 0 } = req.query;

      const reviews = await reviewService.getPendingReviews(parseInt(limit), parseInt(offset));
      sendResponse(res, 200, 'Pending reviews fetched', reviews);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Moderate a review (approve/reject)
   * POST /api/reviews/:reviewId/moderate
   * Body: { approved: boolean, reason?: string }
   */
  async moderateReview(req, res) {
    try {
      validateRequest(req, 'user', 'params', 'body');
      const { reviewId } = req.params;
      const { approved, reason } = req.body;

      if (!reviewId) throw new Error('Review ID is required');
      if (typeof approved !== 'boolean') throw new Error('Approved must be a boolean');

      const review = await reviewService.moderateReview(parseInt(reviewId), approved, reason);
      sendResponse(res, 200, 'Review moderated successfully', review);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Delete review
   * DELETE /api/reviews/:reviewId
   */
  async deleteReview(req, res) {
    try {
      validateRequest(req, 'user', 'params');
      const { reviewId } = req.params;

      if (!reviewId) throw new Error('Review ID is required');

      const result = await reviewService.deleteReview(parseInt(reviewId));
      sendResponse(res, 200, 'Review deleted successfully', result);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get review statistics for a charger
   * GET /api/reviews/stats/charger/:chargerId
   */
  async getReviewStats(req, res) {
    try {
      validateRequest(req, 'params');
      const { chargerId } = req.params;

      if (!chargerId) throw new Error('Charger ID is required');

      const stats = await reviewService.getReviewStatistics(parseInt(chargerId));
      sendResponse(res, 200, 'Review statistics fetched', stats);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get owner's average rating
   * GET /api/reviews/owner-rating
   */
  async getOwnerRating(req, res) {
    try {
      validateRequest(req, 'user');
      const rating = await reviewService.getOwnerAverageRating(req.user.id);
      sendResponse(res, 200, 'Owner rating fetched', rating);
    } catch (error) {
      handleError(res, error);
    }
  }
}

module.exports = new ReviewController();
