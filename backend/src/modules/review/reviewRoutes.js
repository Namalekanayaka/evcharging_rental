import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import {
  createReview,
  getChargerReviews,
  getUserReviews,
  getChargerReviewStats,
  updateReview,
  deleteReview,
} from "./reviewController.js";

const router = express.Router();

router.get("/charger/:id", getChargerReviews);
router.get("/charger/:id/stats", getChargerReviewStats);

router.use(authMiddleware);

router.post("/", createReview);
router.get("/", getUserReviews);
router.put("/:id", updateReview);
router.delete("/:id", deleteReview);

export default router;
