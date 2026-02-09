import express from "express";
import { body, query, param } from "express-validator";
import sessionController from "./sessionController.js";
import { authenticateToken } from "../../middleware/auth.js";

const router = express.Router();

router.use(authenticateToken);

/**
 * POST /api/sessions/start
 * Start a new charging session
 */
router.post("/start", [
  body("chargerId").isInt().withMessage("Valid charger ID required"),
  body("bookingId").isInt().withMessage("Valid booking ID required"),
], (req, res) => sessionController.startSession(req, res));

/**
 * POST /api/sessions/:id/progress
 * Update session progress (IoT endpoint)
 */
router.post("/:id/progress", [
  param("id").isInt(),
  body("currentKwh").isFloat().optional(),
  body("currentBattery").isFloat().optional(),
  body("chargingPower").isFloat().optional(),
  body("voltage").isFloat().optional(),
  body("amperage").isFloat().optional(),
  body("temperature").isFloat().optional(),
], (req, res) => sessionController.updateSessionProgress(req, res));

/**
 * POST /api/sessions/:id/stop
 * Stop a charging session
 */
router.post("/:id/stop", [
  param("id").isInt(),
], (req, res) => sessionController.stopSession(req, res));

/**
 * GET /api/sessions/active
 * Get currently active charging session
 */
router.get("/active", (req, res) => sessionController.getActiveSession(req, res));

/**
 * GET /api/sessions/history
 * Get session history for user
 */
router.get("/history", [
  query("limit").optional().isInt({ min: 1, max: 100 }),
  query("offset").optional().isInt({ min: 0 }),
  query("startDate").optional().isISO8601(),
  query("endDate").optional().isISO8601(),
  query("minCost").optional().isFloat({ min: 0 }),
  query("maxCost").optional().isFloat({ min: 0 }),
], (req, res) => sessionController.getSessionHistory(req, res));

/**
 * GET /api/sessions/stats
 * Get session statistics for user
 */
router.get("/stats", [
  query("startDate").optional().isISO8601(),
  query("endDate").optional().isISO8601(),
], (req, res) => sessionController.getSessionStats(req, res));

/**
 * GET /api/sessions/charger/:chargerId/stats
 * Get session statistics for a charger
 */
router.get("/charger/:chargerId/stats", [
  param("chargerId").isInt(),
  query("startDate").optional().isISO8601(),
  query("endDate").optional().isISO8601(),
], (req, res) => sessionController.getChargerStats(req, res));

/**
 * POST /api/sessions/:id/pause
 * Pause a charging session
 */
router.post("/:id/pause", [
  param("id").isInt(),
], (req, res) => sessionController.pauseSession(req, res));

/**
 * POST /api/sessions/:id/resume
 * Resume a paused session
 */
router.post("/:id/resume", [
  param("id").isInt(),
], (req, res) => sessionController.resumeSession(req, res));

export default router;
