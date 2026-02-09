import express from "express";
import { body, query } from "express-validator";
import searchController from "./searchController.js";
import { authenticateToken } from "../../middleware/auth.js";

const router = express.Router();

/**
 * POST /api/search/nearby
 * Search for chargers near a location with filters
 */
router.post(
  "/nearby",
  [
    body("latitude")
      .isFloat({ min: -90, max: 90 })
      .withMessage("Invalid latitude"),
    body("longitude")
      .isFloat({ min: -180, max: 180 })
      .withMessage("Invalid longitude"),
    body("radiusKm").optional().isFloat({ min: 0.5, max: 100 }),
    body("minPrice").optional().isFloat({ min: 0 }),
    body("maxPrice").optional().isFloat({ min: 0 }),
    body("chargerTypes").optional().isArray(),
    body("minPower").optional().isInt({ min: 0 }),
    body("availability").optional().isBoolean(),
    body("sortBy")
      .optional()
      .isIn(["distance", "price", "rating", "availability", "newest"]),
    body("limit").optional().isInt({ min: 1, max: 100 }),
    body("offset").optional().isInt({ min: 0 }),
  ],
  searchController.searchNearby,
);

/**
 * POST /api/search/recommend
 * Get best charger recommendation
 */
router.post(
  "/recommend",
  [
    body("latitude")
      .isFloat({ min: -90, max: 90 })
      .withMessage("Invalid latitude"),
    body("longitude")
      .isFloat({ min: -180, max: 180 })
      .withMessage("Invalid longitude"),
    body("batteryPercentage").optional().isInt({ min: 0, max: 100 }),
    body("radiusKm").optional().isFloat({ min: 0.5, max: 100 }),
    body("urgentCharging").optional().isBoolean(),
  ],
  searchController.getRecommendation,
);

/**
 * GET /api/search/location
 * Search chargers by address/location name
 */
router.get(
  "/location",
  [
    query("q")
      .trim()
      .isLength({ min: 2 })
      .withMessage("Search query must be at least 2 characters"),
    query("limit").optional().isInt({ min: 1, max: 100 }),
    query("offset").optional().isInt({ min: 0 }),
  ],
  searchController.searchByLocation,
);

/**
 * GET /api/search/chargers/:id/availability
 * Get real-time availability of a charger
 */
router.get("/chargers/:id/availability", searchController.getAvailability);

/**
 * POST /api/search/area
 * Get chargers in map area (bounding box)
 */
router.post(
  "/area",
  [
    body("minLat").isFloat({ min: -90, max: 90 }),
    body("maxLat").isFloat({ min: -90, max: 90 }),
    body("minLng").isFloat({ min: -180, max: 180 }),
    body("maxLng").isFloat({ min: -180, max: 180 }),
  ],
  searchController.getChargersInArea,
);

/**
 * POST /api/search/route
 * Calculate route and estimated time to charger
 */
router.post(
  "/route",
  [
    body("fromLat").isFloat({ min: -90, max: 90 }),
    body("fromLng").isFloat({ min: -180, max: 180 }),
    body("toLat").isFloat({ min: -90, max: 90 }),
    body("toLng").isFloat({ min: -180, max: 180 }),
  ],
  searchController.calculateRoute,
);

/**
 * POST /api/search/advanced
 * Advanced search with multiple criteria
 */
router.post(
  "/advanced",
  [
    body("latitude").isFloat({ min: -90, max: 90 }),
    body("longitude").isFloat({ min: -180, max: 180 }),
    body("radiusKm").optional().isFloat({ min: 0.5 }),
    body("priceRange.min").optional().isFloat({ min: 0 }),
    body("priceRange.max").optional().isFloat({ min: 0 }),
    body("chargerTypes").optional().isArray(),
    body("minPowerOutput").optional().isInt({ min: 0 }),
    body("minRating").optional().isFloat({ min: 0, max: 5 }),
    body("availableOnly").optional().isBoolean(),
    body("sortBy")
      .optional()
      .isIn(["distance", "price", "rating", "availability"]),
  ],
  searchController.advancedSearch,
);

/**
 * GET /api/search/trending
 * Get trending/popular chargers
 */
router.get(
  "/trending",
  [
    query("limit").optional().isInt({ min: 1, max: 50 }),
    query("radiusKm").optional().isFloat({ min: 0.5 }),
  ],
  searchController.getTrendingChargers,
);

export default router;
