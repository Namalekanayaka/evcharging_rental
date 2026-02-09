/**
 * Review Routes
 * Routes for charger reviews, ratings, and trust scores
 */

const express = require("express");
const router = express.Router();
const reviewController = require("../controllers/reviewController");
const { authenticate } = require("../middleware/authMiddleware");

// Public routes
router.get("/charger/:chargerId", reviewController.getChargerReviews);
router.get("/stats/charger/:chargerId", reviewController.getReviewStats);

// Protected routes (require authentication)
router.post("/", authenticate, reviewController.submitReview);
router.get("/my-reviews", authenticate, reviewController.getUserReviews);
router.get("/trust-score", authenticate, reviewController.getUserTrustScore);
router.get("/owner-rating", authenticate, reviewController.getOwnerRating);
router.post("/:reviewId/helpful", authenticate, reviewController.markHelpful);
router.post(
  "/:reviewId/unhelpful",
  authenticate,
  reviewController.markUnhelpful,
);
router.delete("/:reviewId", authenticate, reviewController.deleteReview);

// Admin routes
router.get("/pending", authenticate, reviewController.getPendingReviews);
router.post(
  "/:reviewId/moderate",
  authenticate,
  reviewController.moderateReview,
);

module.exports = router;
