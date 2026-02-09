import express from "express";
import * as aiController from "./aiController.js";
import { authenticate } from "../../middleware/authMiddleware.js";

const router = express.Router();

// Public routes
router.post("/battery-range", aiController.predictBatteryRange);
router.post("/nearest-chargers", aiController.findNearestChargers);
router.get("/demand-pricing/:chargerId", aiController.predictDemandPricing);
router.post("/optimize-route", aiController.optimizeRoute);

// Protected routes (require authentication)
router.get("/recommendations", authenticate, aiController.getRecommendations);

export default router;
