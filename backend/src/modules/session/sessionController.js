import { validationResult } from "express-validator";
import sessionService from "./sessionService.js";
import { successResponse, errorResponse } from "../../utils/responseHandler.js";

class SessionController {
  /**
   * Start a charging session
   * POST /api/sessions/start
   */
  async startSession(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return errorResponse(res, "Validation failed", 400, errors.array());
      }

      const userId = req.user.id;
      const { chargerId, bookingId } = req.body;

      const session = await sessionService.startSession(
        chargerId,
        bookingId,
        userId,
      );

      return successResponse(res, "Session started successfully", session, 201);
    } catch (error) {
      console.error("Start session error:", error);
      return errorResponse(res, error.message, 400);
    }
  }

  /**
   * Update session progress (from IoT)
   * POST /api/sessions/:id/progress
   */
  async updateSessionProgress(req, res) {
    try {
      const { id } = req.params;
      const {
        currentKwh,
        currentBattery,
        chargingPower,
        voltage,
        amperage,
        temperature,
      } = req.body;

      const session = await sessionService.updateSessionProgress(id, {
        currentKwh,
        currentBattery,
        chargingPower,
        voltage,
        amperage,
        temperature,
      });

      return successResponse(res, "Session updated", session, 200);
    } catch (error) {
      console.error("Update session error:", error);
      return errorResponse(res, error.message, 400);
    }
  }

  /**
   * Stop charging session
   * POST /api/sessions/:id/stop
   */
  async stopSession(req, res) {
    try {
      const { id } = req.params;

      const result = await sessionService.stopSession(id);

      return successResponse(
        res,
        "Session completed successfully",
        result,
        200,
      );
    } catch (error) {
      console.error("Stop session error:", error);
      return errorResponse(res, error.message, 400);
    }
  }

  /**
   * Get active session
   * GET /api/sessions/active
   */
  async getActiveSession(req, res) {
    try {
      const userId = req.user.id;

      const session = await sessionService.getActiveSession(userId);

      if (!session) {
        return successResponse(res, "No active session", { session: null }, 200);
      }

      return successResponse(res, "Active session found", session, 200);
    } catch (error) {
      console.error("Get active session error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Get session history
   * GET /api/sessions/history
   */
  async getSessionHistory(req, res) {
    try {
      const userId = req.user.id;
      const {
        limit = 20,
        offset = 0,
        startDate,
        endDate,
        minCost,
        maxCost,
      } = req.query;

      const sessions = await sessionService.getSessionHistory(userId, {
        limit: Math.min(parseInt(limit) || 20, 100),
        offset: parseInt(offset) || 0,
        startDate: startDate ? new Date(startDate) : null,
        endDate: endDate ? new Date(endDate) : null,
        minCost: minCost ? parseFloat(minCost) : null,
        maxCost: maxCost ? parseFloat(maxCost) : null,
      });

      return successResponse(
        res,
        "Session history retrieved",
        {
          sessions,
          count: sessions.length,
        },
        200,
      );
    } catch (error) {
      console.error("Get session history error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Get session statistics
   * GET /api/sessions/stats
   */
  async getSessionStats(req, res) {
    try {
      const userId = req.user.id;
      const { startDate, endDate } = req.query;

      const stats = await sessionService.getSessionStats(userId, {
        startDate: startDate ? new Date(startDate) : null,
        endDate: endDate ? new Date(endDate) : null,
      });

      return successResponse(res, "Session statistics retrieved", stats, 200);
    } catch (error) {
      console.error("Get stats error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Get charger session statistics
   * GET /api/sessions/charger/:chargerId/stats
   */
  async getChargerStats(req, res) {
    try {
      const { chargerId } = req.params;
      const { startDate, endDate } = req.query;

      const stats = await sessionService.getChargerSessionStats(chargerId, {
        startDate: startDate ? new Date(startDate) : null,
        endDate: endDate ? new Date(endDate) : null,
      });

      return successResponse(
        res,
        "Charger statistics retrieved",
        stats,
        200,
      );
    } catch (error) {
      console.error("Get charger stats error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Pause session
   * POST /api/sessions/:id/pause
   */
  async pauseSession(req, res) {
    try {
      const { id } = req.params;

      const session = await sessionService.pauseSession(id);

      return successResponse(res, "Session paused", session, 200);
    } catch (error) {
      console.error("Pause session error:", error);
      return errorResponse(res, error.message, 400);
    }
  }

  /**
   * Resume session
   * POST /api/sessions/:id/resume
   */
  async resumeSession(req, res) {
    try {
      const { id } = req.params;

      const session = await sessionService.resumeSession(id);

      return successResponse(res, "Session resumed", session, 200);
    } catch (error) {
      console.error("Resume session error:", error);
      return errorResponse(res, error.message, 400);
    }
  }
}

export default new SessionController();
