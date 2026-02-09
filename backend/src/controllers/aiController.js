/**
 * AI Controller
 * Handles incoming requests for AI services
 */

const AIService = require("../services/aiService");

class AIController {
  constructor(db) {
    this.aiService = new AIService(db);
  }

  /**
   * Predict battery range
   * POST /api/ai/battery-range
   * Body: { carModel, currentBattery, weather }
   */
  async predictBatteryRange(req, res) {
    try {
      const { carModel, currentBattery, weather = "normal" } = req.body;

      if (!carModel || currentBattery === undefined) {
        return res.status(400).json({
          success: false,
          error: "carModel and currentBattery are required",
        });
      }

      if (currentBattery < 0 || currentBattery > 100) {
        return res.status(400).json({
          success: false,
          error: "currentBattery must be between 0 and 100",
        });
      }

      const prediction = await this.aiService.predictBatteryRange(
        carModel,
        currentBattery,
        weather,
      );

      res.json({
        success: true,
        data: prediction,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Find nearest chargers within range
   * POST /api/ai/nearest-chargers
   * Body: { userLocation, currentBattery, carModel, weather }
   */
  async findNearestChargers(req, res) {
    try {
      const {
        userLocation,
        currentBattery,
        carModel,
        weather = "normal",
      } = req.body;

      if (!userLocation || currentBattery === undefined || !carModel) {
        return res.status(400).json({
          success: false,
          error: "userLocation, currentBattery, and carModel are required",
        });
      }

      if (!userLocation.latitude || !userLocation.longitude) {
        return res.status(400).json({
          success: false,
          error: "userLocation must include latitude and longitude",
        });
      }

      const chargers = await this.aiService.findNearestChargerWithinRange(
        userLocation,
        currentBattery,
        carModel,
        weather,
      );

      res.json({
        success: true,
        data: chargers,
        count: chargers.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Predict demand-based pricing
   * GET /api/ai/demand-pricing/:chargerId
   * Query: { dateTime }
   */
  async predictDemandPricing(req, res) {
    try {
      const { chargerId } = req.params;
      const { dateTime } = req.query;

      if (!chargerId) {
        return res.status(400).json({
          success: false,
          error: "chargerId is required",
        });
      }

      const targetDate = dateTime ? new Date(dateTime) : new Date();

      const prediction = await this.aiService.predictDemandBasedPricing(
        parseInt(chargerId),
        targetDate,
      );

      res.json({
        success: true,
        data: prediction,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Optimize charging route
   * POST /api/ai/optimize-route
   * Body: { locations, carModel, currentBattery, weather }
   */
  async optimizeRoute(req, res) {
    try {
      const {
        locations,
        carModel,
        currentBattery,
        weather = "normal",
      } = req.body;

      if (
        !locations ||
        locations.length === 0 ||
        !carModel ||
        currentBattery === undefined
      ) {
        return res.status(400).json({
          success: false,
          error: "locations, carModel, and currentBattery are required",
        });
      }

      const optimizedRoute = await this.aiService.optimizeChargingRoute(
        locations,
        carModel,
        currentBattery,
        weather,
      );

      res.json({
        success: true,
        data: optimizedRoute,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get AI recommendations
   * GET /api/ai/recommendations
   */
  async getRecommendations(req, res) {
    try {
      const userId = req.user?.id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          error: "User not authenticated",
        });
      }

      const recommendations = await this.aiService.getRecommendations(userId);

      res.json({
        success: true,
        data: recommendations,
        count: recommendations.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }
}

module.exports = AIController;
