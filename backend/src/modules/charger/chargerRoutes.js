import express from "express";
import authMiddleware from "../../middleware/authMiddleware.js";
import {
  createCharger,
  updateCharger,
  getChargerById,
  searchChargers,
  getOwnerChargers,
  deleteCharger,
  getChargerAvailability,
  setAvailability,
  getUsageHistory,
  startChargingSession,
  endChargingSession,
  addChargerReview,
  getChargerReviews,
  getNearbyChargers,
  getChargerStats,
  uploadChargerPhoto,
} from "./chargerController.js";

const router = express.Router();

// Public routes
router.get("/search", searchChargers);
router.get("/nearby", getNearbyChargers);
router.get("/:id", getChargerById);
router.get("/:id/reviews", getChargerReviews);
router.get("/:id/usage", getUsageHistory);
router.get("/:id/stats", getChargerStats);
router.get("/:id/availability", getChargerAvailability);

// Protected routes (require authentication)
router.use(authMiddleware);

router.post("/", createCharger);
router.get("/", getOwnerChargers);
router.put("/:id", updateCharger);
router.delete("/:id", deleteCharger);

// Charger management routes
router.post("/:id/availability", setAvailability);
router.post("/:id/start-session", startChargingSession);
router.put("/:id/end-session/:sessionId", endChargingSession);
router.post("/:id/reviews", addChargerReview);
router.post("/:id/photos", uploadChargerPhoto);

export default router;
