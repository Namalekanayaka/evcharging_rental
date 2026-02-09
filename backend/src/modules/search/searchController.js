import { validationResult } from "express-validator";
import searchService from "./searchService.js";
import { successResponse, errorResponse } from "../../utils/responseHandler.js";

class SearchController {
  /**
   * Search nearby chargers
   * POST /api/search/nearby
   */
  async searchNearby(req, res) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return errorResponse(res, "Validation failed", 400, errors.array());
      }

      const {
        latitude,
        longitude,
        radiusKm,
        maxPrice,
        minPrice,
        chargerTypes,
        minPower,
        availability,
        sortBy,
        limit,
        offset,
      } = req.body;

      const chargers = await searchService.searchNearbyChargers({
        latitude,
        longitude,
        radiusKm,
        maxPrice,
        minPrice,
        chargerTypes: chargerTypes || [],
        minPower: minPower || 0,
        availability: availability !== false,
        sortBy,
        limit: Math.min(limit || 20, 100), // Max 100
        offset: offset || 0,
      });

      return successResponse(
        res,
        "Chargers found",
        {
          chargers,
          count: chargers.length,
        },
        200,
      );
    } catch (error) {
      console.error("Search nearby error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Get best charger recommendation
   * POST /api/search/recommend
   */
  async getRecommendation(req, res) {
    try {
      const {
        latitude,
        longitude,
        batteryPercentage,
        radiusKm,
        urgentCharging,
      } = req.body;

      if (!latitude || !longitude) {
        return errorResponse(res, "Location is required", 400);
      }

      const charger = await searchService.getRecommendedCharger({
        latitude,
        longitude,
        batteryPercentage,
        radiusKm,
        urgentCharging,
      });

      if (!charger) {
        return successResponse(
          res,
          "No chargers available",
          { charger: null },
          200,
        );
      }

      return successResponse(res, "Recommended charger", { charger }, 200);
    } catch (error) {
      console.error("Recommendation error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Search chargers by location/address
   * GET /api/search/location
   */
  async searchByLocation(req, res) {
    try {
      const { q, limit, offset } = req.query;

      if (!q || q.trim().length < 2) {
        return errorResponse(res, "Query must be at least 2 characters", 400);
      }

      const chargers = await searchService.searchByLocation(q, {
        limit: Math.min(parseInt(limit) || 20, 100),
        offset: parseInt(offset) || 0,
      });

      return successResponse(
        res,
        "Location search results",
        {
          chargers,
          count: chargers.length,
          query: q,
        },
        200,
      );
    } catch (error) {
      console.error("Location search error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Get charger availability
   * GET /api/search/chargers/:id/availability
   */
  async getAvailability(req, res) {
    try {
      const { id } = req.params;

      const availability = await searchService.getChargerAvailability(id);

      if (!availability) {
        return errorResponse(res, "Charger not found", 404);
      }

      return successResponse(res, "Availability data", availability, 200);
    } catch (error) {
      console.error("Availability check error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Get chargers in map area (for map visualization)
   * POST /api/search/area
   */
  async getChargersInArea(req, res) {
    try {
      const { minLat, maxLat, minLng, maxLng } = req.body;

      if (
        minLat === undefined ||
        maxLat === undefined ||
        minLng === undefined ||
        maxLng === undefined
      ) {
        return errorResponse(res, "Bounding box coordinates are required", 400);
      }

      const chargers = await searchService.getChargersInArea({
        minLat,
        maxLat,
        minLng,
        maxLng,
      });

      return successResponse(
        res,
        "Chargers in area",
        {
          chargers,
          count: chargers.length,
          bounds: { minLat, maxLat, minLng, maxLng },
        },
        200,
      );
    } catch (error) {
      console.error("Area search error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Calculate route and time to charger
   * POST /api/search/route
   */
  async calculateRoute(req, res) {
    try {
      const { fromLat, fromLng, toLat, toLng } = req.body;

      if (
        fromLat === undefined ||
        fromLng === undefined ||
        toLat === undefined ||
        toLng === undefined
      ) {
        return errorResponse(
          res,
          "from (Lat/Lng) and to (Lat/Lng) coordinates are required",
          400,
        );
      }

      const route = await searchService.calculateRoute(
        fromLat,
        fromLng,
        toLat,
        toLng,
      );

      return successResponse(res, "Route calculated", route, 200);
    } catch (error) {
      console.error("Route calculation error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Advanced search with multiple filters
   * POST /api/search/advanced
   */
  async advancedSearch(req, res) {
    try {
      const {
        latitude,
        longitude,
        radiusKm = 15,
        priceRange = { min: 0, max: 100 },
        chargerTypes = [],
        minPowerOutput = 0,
        minRating = 0,
        availableOnly = true,
        sortBy = "distance",
      } = req.body;

      if (!latitude || !longitude) {
        return errorResponse(res, "Location is required", 400);
      }

      // Get all chargers matching criteria
      const chargers = await searchService.searchNearbyChargers({
        latitude,
        longitude,
        radiusKm,
        maxPrice: priceRange.max,
        minPrice: priceRange.min,
        chargerTypes,
        minPower: minPowerOutput,
        availability: availableOnly,
        sortBy,
        limit: 100,
      });

      // Filter by rating if specified
      const filtered = chargers.filter((c) => c.rating >= minRating);

      return successResponse(
        res,
        "Advanced search results",
        {
          searchCriteria: {
            location: { latitude, longitude },
            radius: radiusKm,
            priceRange,
            chargerTypes,
            minRating,
            availableOnly,
          },
          results: filtered,
          count: filtered.length,
        },
        200,
      );
    } catch (error) {
      console.error("Advanced search error:", error);
      return errorResponse(res, error.message, 500);
    }
  }

  /**
   * Get trending/popular chargers
   * GET /api/search/trending
   */
  async getTrendingChargers(req, res) {
    try {
      const { limit = 10, radiusKm = 50 } = req.query;
      const userLocation = req.body?.location || { latitude: 0, longitude: 0 };

      // Get chargers sorted by rating and recent bookings
      const chargers = await searchService.searchNearbyChargers({
        latitude: userLocation.latitude,
        longitude: userLocation.longitude,
        radiusKm: parseInt(radiusKm),
        sortBy: "rating",
        limit: Math.min(parseInt(limit) || 10, 50),
      });

      return successResponse(
        res,
        "Trending chargers",
        {
          chargers,
          count: chargers.length,
        },
        200,
      );
    } catch (error) {
      console.error("Trending chargers error:", error);
      return errorResponse(res, error.message, 500);
    }
  }
}

export default new SearchController();
