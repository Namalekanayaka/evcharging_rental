import db from "../../config/database.js";

class SearchService {
  /**
   * Search nearby chargers with advanced filtering
   * @param {Object} params - Search parameters
   * @returns {Promise<Array>} List of chargers matching criteria
   */
  async searchNearbyChargers(params) {
    const {
      latitude,
      longitude,
      radiusKm = 10,
      maxPrice = 100,
      minPrice = 0,
      chargerTypes = [],
      minPower = 0,
      availability = true,
      sortBy = "distance",
      limit = 20,
      offset = 0,
    } = params;

    try {
      // Validate location
      if (!latitude || !longitude) {
        throw new Error("Latitude and longitude are required");
      }

      let query = `
        SELECT 
          c.*,
          u.name as owner_name,
          u.profile_picture,
          (
            6371 * acos(
              cos(radians($1)) * cos(radians(c.latitude)) * 
              cos(radians(c.longitude) - radians($2)) + 
              sin(radians($1)) * sin(radians(c.latitude))
            )
          ) as distance_km,
          COALESCE(c.average_rating, 0) as rating,
          (
            SELECT COUNT(*) 
            FROM bookings b 
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved')
          ) as active_bookings,
          (c.total_ports - COALESCE(
            SELECT COUNT(*) 
            FROM bookings b 
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved'),
            0
          )) as available_ports
        FROM chargers c
        JOIN users u ON c.owner_id = u.id
        WHERE 
          (
            6371 * acos(
              cos(radians($1)) * cos(radians(c.latitude)) * 
              cos(radians(c.longitude) - radians($2)) + 
              sin(radians($1)) * sin(radians(c.latitude))
            )
          ) <= $3
      `;

      const params_array = [latitude, longitude, radiusKm];
      let param_index = 4;

      // Filter by price
      query += ` AND c.price_per_kwh BETWEEN $${param_index} AND $${param_index + 1}`;
      params_array.push(minPrice, maxPrice);
      param_index += 2;

      // Filter by charger type
      if (chargerTypes.length > 0) {
        query += ` AND c.charger_type = ANY($${param_index}::text[])`;
        params_array.push(chargerTypes);
        param_index += 1;
      }

      // Filter by power output
      query += ` AND c.power_output >= $${param_index}`;
      params_array.push(minPower);
      param_index += 1;

      // Filter by availability
      if (availability) {
        query += ` AND COALESCE((
          SELECT COUNT(*) 
          FROM bookings b 
          WHERE b.charger_id = c.id 
          AND b.status IN ('active', 'reserved')
        ), 0) < c.total_ports`;
      }

      // Filter by status
      query += ` AND c.status = 'active'`;

      // Sorting
      switch (sortBy) {
        case "distance":
          query += ` ORDER BY distance_km ASC`;
          break;
        case "price":
          query += ` ORDER BY c.price_per_kwh ASC`;
          break;
        case "rating":
          query += ` ORDER BY rating DESC, distance_km ASC`;
          break;
        case "availability":
          query += ` ORDER BY available_ports DESC, distance_km ASC`;
          break;
        case "newest":
          query += ` ORDER BY c.created_at DESC`;
          break;
        default:
          query += ` ORDER BY distance_km ASC`;
      }

      // Pagination
      query += ` LIMIT $${param_index} OFFSET $${param_index + 1}`;
      params_array.push(limit, offset);

      const result = await db.query(query, params_array);
      return result.rows;
    } catch (error) {
      throw new Error(`Search failed: ${error.message}`);
    }
  }

  /**
   * Get best charger recommendation based on multiple criteria
   * @param {Object} params - Parameters for recommendation
   * @returns {Promise<Object>} Recommended charger
   */
  async getRecommendedCharger(params) {
    const {
      latitude,
      longitude,
      batteryPercentage = 50,
      radiusKm = 10,
      urgentCharging = false,
    } = params;

    try {
      let query = `
        SELECT 
          c.*,
          u.name as owner_name,
          (
            6371 * acos(
              cos(radians($1)) * cos(radians(c.latitude)) * 
              cos(radians(c.longitude) - radians($2)) + 
              sin(radians($1)) * sin(radians(c.latitude))
            )
          ) as distance_km,
          COALESCE(c.average_rating, 0) as rating,
          (c.total_ports - COALESCE(
            SELECT COUNT(*) 
            FROM bookings b 
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved'),
            0
          )) as available_ports,
          -- Score calculation
          (
            -- Distance factor (closer is better, 0-25 points)
            CASE 
              WHEN distance_km <= 1 THEN 25
              WHEN distance_km <= 3 THEN 20
              WHEN distance_km <= 5 THEN 15
              WHEN distance_km <= 10 THEN 10
              ELSE 0
            END +
            -- Power factor (faster charging, 0-25 points)
            CASE 
              WHEN c.power_output >= 150 THEN 25
              WHEN c.power_output >= 100 THEN 20
              WHEN c.power_output >= 50 THEN 15
              ELSE 10
            END +
            -- Rating factor (0-25 points)
            (COALESCE(c.average_rating, 0) / 5 * 25) +
            -- Availability factor (0-25 points)
            CASE 
              WHEN (c.total_ports - COALESCE(
                SELECT COUNT(*) 
                FROM bookings b 
                WHERE b.charger_id = c.id 
                AND b.status IN ('active', 'reserved'),
                0
              )) >= 3 THEN 25
              WHEN (c.total_ports - COALESCE(
                SELECT COUNT(*) 
                FROM bookings b 
                WHERE b.charger_id = c.id 
                AND b.status IN ('active', 'reserved'),
                0
              )) >= 1 THEN 15
              ELSE 5
            END
          ) as recommendation_score
        FROM chargers c
        JOIN users u ON c.owner_id = u.id
        WHERE 
          c.status = 'active'
          AND (
            6371 * acos(
              cos(radians($1)) * cos(radians(c.latitude)) * 
              cos(radians(c.longitude) - radians($2)) + 
              sin(radians($1)) * sin(radians(c.latitude))
            )
          ) <= $3
          AND (c.total_ports - COALESCE(
            SELECT COUNT(*) 
            FROM bookings b 
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved'),
            0
          )) > 0
      `;

      // Adjust criteria for urgent charging
      if (urgentCharging) {
        query += ` AND c.power_output >= 50`; // At least 50kW for urgent charging
      }

      query += ` ORDER BY recommendation_score DESC LIMIT 1`;

      const result = await db.query(query, [latitude, longitude, radiusKm]);
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Recommendation failed: ${error.message}`);
    }
  }

  /**
   * Search chargers by address or location name
   * @param {string} query - Search query (address, city, etc.)
   * @param {Object} options - Search options
   * @returns {Promise<Array>} Matching chargers
   */
  async searchByLocation(query, options = {}) {
    const { limit = 20, offset = 0 } = options;

    try {
      const searchQuery = `
        SELECT c.*,
               u.name as owner_name,
               COALESCE(c.average_rating, 0) as rating,
               (c.total_ports - COALESCE(
                 SELECT COUNT(*) 
                 FROM bookings b 
                 WHERE b.charger_id = c.id 
                 AND b.status IN ('active', 'reserved'),
                 0
               )) as available_ports
        FROM chargers c
        JOIN users u ON c.owner_id = u.id
        WHERE c.status = 'active' AND (
          LOWER(c.address) LIKE LOWER($1) OR
          LOWER(c.city) LIKE LOWER($1) OR
          LOWER(c.location_name) LIKE LOWER($1)
        )
        ORDER BY c.created_at DESC
        LIMIT $2 OFFSET $3
      `;

      const result = await db.query(searchQuery, [`%${query}%`, limit, offset]);

      return result.rows;
    } catch (error) {
      throw new Error(`Location search failed: ${error.message}`);
    }
  }

  /**
   * Get charger availability details
   * @param {number} chargerId - Charger ID
   * @returns {Promise<Object>} Availability details
   */
  async getChargerAvailability(chargerId) {
    try {
      const query = `
        SELECT 
          c.id,
          c.total_ports,
          COALESCE(
            SELECT COUNT(*) 
            FROM bookings b 
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved')
          , 0) as occupied_ports,
          (c.total_ports - COALESCE(
            SELECT COUNT(*) 
            FROM bookings b 
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved')
          , 0)) as available_ports,
          (
            SELECT json_agg(
              json_build_object(
                'status', b.status,
                'end_time', b.end_time,
                'user', u.name
              )
            ) FROM bookings b
            JOIN users u ON b.user_id = u.id
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved')
          ) as current_bookings,
          c.status,
          c.last_maintenance
        FROM chargers c
        WHERE c.id = $1
      `;

      const result = await db.query(query, [chargerId]);
      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Availability check failed: ${error.message}`);
    }
  }

  /**
   * Get chargers in a specific area with advanced analytics
   * @param {Object} boundingBox - Map bounding box coordinates
   * @returns {Promise<Array>} Chargers in the area with stats
   */
  async getChargersInArea(boundingBox) {
    const { minLat, maxLat, minLng, maxLng } = boundingBox;

    try {
      const query = `
        SELECT 
          c.id,
          c.latitude,
          c.longitude,
          c.location_name,
          c.charger_type,
          c.power_output,
          c.price_per_kwh,
          COALESCE(c.average_rating, 0) as rating,
          (c.total_ports - COALESCE(
            SELECT COUNT(*) 
            FROM bookings b 
            WHERE b.charger_id = c.id 
            AND b.status IN ('active', 'reserved'),
            0
          )) as available_ports,
          c.total_ports,
          c.status
        FROM chargers c
        WHERE c.status = 'active'
          AND c.latitude BETWEEN $1 AND $2
          AND c.longitude BETWEEN $3 AND $4
        ORDER BY c.average_rating DESC
      `;

      const result = await db.query(query, [minLat, maxLat, minLng, maxLng]);
      return result.rows;
    } catch (error) {
      throw new Error(`Area search failed: ${error.message}`);
    }
  }

  /**
   * Calculate route and estimate time to charger
   * @param {number} fromLat - Start latitude
   * @param {number} fromLng - Start longitude
   * @param {number} toLat - Charger latitude
   * @param {number} toLng - Charger longitude
   * @returns {Promise<Object>} Distance and estimated time
   */
  async calculateRoute(fromLat, fromLng, toLat, toLng) {
    try {
      // Using Haversine formula for distance
      const distanceKm = this._calculateDistance(
        fromLat,
        fromLng,
        toLat,
        toLng,
      );

      // Estimate travel time (average 40 km/h urban speed)
      const estimatedMinutes = Math.round((distanceKm / 40) * 60);

      return {
        distanceKm: parseFloat(distanceKm.toFixed(2)),
        estimatedMinutes,
        estimatedTime: `${estimatedMinutes} min`,
      };
    } catch (error) {
      throw new Error(`Route calculation failed: ${error.message}`);
    }
  }

  /**
   * Haversine formula to calculate distance between two coordinates
   * @private
   */
  _calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth radius in km
    const dLat = ((lat2 - lat1) * Math.PI) / 180;
    const dLon = ((lon2 - lon1) * Math.PI) / 180;

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos((lat1 * Math.PI) / 180) *
        Math.cos((lat2 * Math.PI) / 180) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }
}

export default new SearchService();
