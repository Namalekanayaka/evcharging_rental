import db from '../../../infrastructure/database.js';

/**
 * Charger Service
 * Handles all charger-related business logic
 */
class ChargerService {
  /**
   * Create a new charger
   */
  async createCharger({
    ownerId,
    name,
    description,
    chargerType,
    powerKw,
    address,
    city,
    state,
    postalCode,
    country = 'USA',
    latitude,
    longitude,
    pricePerKwh,
    pricePerHour,
    allowReservations = true,
    reservationTimeLimit,
    isPublic = true,
  }) {
    try {
      const query = `
        INSERT INTO chargers (
          owner_id, name, description, charger_type, power_kw,
          address, city, state, postal_code, country,
          latitude, longitude, price_per_kwh, price_per_hour,
          allow_reservations, reservation_time_limit, is_public, status
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, 'ACTIVE'
        )
        RETURNING *;
      `;

      const result = await db.query(query, [
        ownerId,
        name,
        description,
        chargerType.toUpperCase(),
        powerKw,
        address,
        city,
        state,
        postalCode,
        country,
        latitude,
        longitude,
        pricePerKwh,
        pricePerHour,
        allowReservations,
        reservationTimeLimit,
        isPublic,
      ]);

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to create charger: ${error.message}`);
    }
  }

  /**
   * Update charger details
   */
  async updateCharger(chargerId, updates) {
    try {
      const allowedFields = [
        'name',
        'description',
        'charger_type',
        'power_kw',
        'address',
        'city',
        'state',
        'postal_code',
        'country',
        'latitude',
        'longitude',
        'price_per_kwh',
        'price_per_hour',
        'allow_reservations',
        'reservation_time_limit',
        'is_public',
        'status',
      ];

      let query = 'UPDATE chargers SET updated_at = CURRENT_TIMESTAMP';
      const values = [];
      let paramCount = 1;

      for (const [key, value] of Object.entries(updates)) {
        if (allowedFields.includes(key) && value !== undefined) {
          query += `, ${key} = $${paramCount}`;
          values.push(value);
          paramCount++;
        }
      }

      query += ` WHERE id = $${paramCount} RETURNING *;`;
      values.push(chargerId);

      const result = await db.query(query, values);

      if (result.rows.length === 0) {
        throw new Error('Charger not found');
      }

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to update charger: ${error.message}`);
    }
  }

  /**
   * Get charger by ID with details
   */
  async getChargerById(chargerId) {
    try {
      const query = `
        SELECT c.*, 
               u.first_name AS owner_first_name, 
               u.last_name AS owner_last_name,
               u.average_rating AS owner_rating,
               COUNT(DISTINCT cuh.id) AS total_sessions,
               AVG(cr.rating) AS avg_rating,
               COUNT(DISTINCT cr.id) AS total_reviews
        FROM chargers c
        LEFT JOIN users u ON c.owner_id = u.id
        LEFT JOIN charger_usage_history cuh ON c.id = cuh.charger_id
        LEFT JOIN charger_reviews cr ON c.id = cr.charger_id
        WHERE c.id = $1
        GROUP BY c.id, u.id;
      `;

      const result = await db.query(query, [chargerId]);

      if (result.rows.length === 0) {
        return null;
      }

      const charger = result.rows[0];

      // Get availability schedule
      const availQuery = `
        SELECT day_of_week, start_time, end_time, is_available
        FROM charger_availability
        WHERE charger_id = $1
        ORDER BY day_of_week;
      `;
      const availResult = await db.query(availQuery, [chargerId]);
      charger.availability = availResult.rows;

      // Get photos
      const photosQuery = `
        SELECT id, photo_url, display_order, is_primary
        FROM charger_photos
        WHERE charger_id = $1
        ORDER BY is_primary DESC, display_order;
      `;
      const photosResult = await db.query(photosQuery, [chargerId]);
      charger.photos = photosResult.rows;

      return charger;
    } catch (error) {
      throw new Error(`Failed to get charger: ${error.message}`);
    }
  }

  /**
   * List chargers with filtering and pagination
   */
  async listChargers({
    page = 1,
    limit = 20,
    city,
    chargerType,
    minRating,
    maxPrice,
    latitude,
    longitude,
    radius = 50, // km
    ownerId,
    status = 'ACTIVE',
  }) {
    try {
      let query = `
        SELECT c.id, c.name, c.charger_type, c.power_kw, c.city, 
               c.latitude, c.longitude, c.price_per_kwh, c.price_per_hour,
               c.status, c.avg_rating, c.total_reviews, c.total_sessions,
               c.created_at,
               u.first_name AS owner_first_name, u.last_name AS owner_last_name,
               u.average_rating AS owner_rating
        FROM chargers c
        LEFT JOIN users u ON c.owner_id = u.id
        WHERE c.is_public = true AND c.status = $1
      `;
      const params = [status];
      let paramCount = 2;

      // City filter
      if (city) {
        query += ` AND LOWER(c.city) = LOWER($${paramCount})`;
        params.push(city);
        paramCount++;
      }

      // Charger type filter
      if (chargerType) {
        query += ` AND c.charger_type = $${paramCount}`;
        params.push(chargerType.toUpperCase());
        paramCount++;
      }

      // Rating filter
      if (minRating) {
        query += ` AND c.avg_rating >= $${paramCount}`;
        params.push(minRating);
        paramCount++;
      }

      // Price filter
      if (maxPrice) {
        query += ` AND (c.price_per_kwh <= $${paramCount} OR c.price_per_hour <= $${paramCount})`;
        params.push(maxPrice);
        paramCount++;
      }

      // Location filter (distance calculation)
      if (latitude && longitude) {
        query += ` AND (
          6371 * acos(
            cos(RADIANS($${paramCount})) * cos(RADIANS(c.latitude)) *
            cos(RADIANS(c.longitude) - RADIANS($${paramCount + 1})) +
            sin(RADIANS($${paramCount})) * sin(RADIANS(c.latitude))
          )
        ) <= $${paramCount + 2}`;
        params.push(latitude, longitude, radius);
        paramCount += 3;
      }

      // Owner filter
      if (ownerId) {
        query += ` AND c.owner_id = $${paramCount}`;
        params.push(ownerId);
        paramCount++;
      }

      // Sorting and pagination
      query += ` ORDER BY c.created_at DESC LIMIT $${paramCount} OFFSET $${paramCount + 1};`;
      params.push(limit, (page - 1) * limit);

      const result = await db.query(query, params);

      // Get total count
      let countQuery = `
        SELECT COUNT(*) as total FROM chargers c
        WHERE c.is_public = true AND c.status = $1
      `;
      const countParams = [status];
      let countParamCount = 2;

      if (city) {
        countQuery += ` AND LOWER(c.city) = LOWER($${countParamCount})`;
        countParams.push(city);
        countParamCount++;
      }

      if (chargerType) {
        countQuery += ` AND c.charger_type = $${countParamCount}`;
        countParams.push(chargerType.toUpperCase());
        countParamCount++;
      }

      const countResult = await db.query(countQuery, countParams);

      return {
        chargers: result.rows,
        total: parseInt(countResult.rows[0].total),
        page,
        limit,
        pages: Math.ceil(parseInt(countResult.rows[0].total) / limit),
      };
    } catch (error) {
      throw new Error(`Failed to list chargers: ${error.message}`);
    }
  }

  /**
   * Delete charger
   */
  async deleteCharger(chargerId) {
    try {
      const query = 'DELETE FROM chargers WHERE id = $1 RETURNING id;';
      const result = await db.query(query, [chargerId]);

      if (result.rows.length === 0) {
        throw new Error('Charger not found');
      }

      return { success: true, chargerId };
    } catch (error) {
      throw new Error(`Failed to delete charger: ${error.message}`);
    }
  }

  /**
   * Update charger availability schedule
   */
  async setAvailability(chargerId, dayOfWeek, startTime, endTime, isAvailable = true) {
    try {
      const query = `
        INSERT INTO charger_availability (charger_id, day_of_week, start_time, end_time, is_available)
        VALUES ($1, $2, $3, $4, $5)
        ON CONFLICT (charger_id, day_of_week) 
        DO UPDATE SET start_time = $3, end_time = $4, is_available = $5
        RETURNING *;
      `;

      const result = await db.query(query, [chargerId, dayOfWeek, startTime, endTime, isAvailable]);

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to set availability: ${error.message}`);
    }
  }

  /**
   * Get charger usage history
   */
  async getUsageHistory(chargerId, limit = 50, offset = 0) {
    try {
      const query = `
        SELECT cuh.*, u.first_name, u.last_name, u.email
        FROM charger_usage_history cuh
        JOIN users u ON cuh.user_id = u.id
        WHERE cuh.charger_id = $1
        ORDER BY cuh.session_start DESC
        LIMIT $2 OFFSET $3;
      `;

      const result = await db.query(query, [chargerId, limit, offset]);

      return result.rows;
    } catch (error) {
      throw new Error(`Failed to get usage history: ${error.message}`);
    }
  }

  /**
   * Start a charging session
   */
  async startChargingSession(chargerId, userId, bookingId = null) {
    try {
      const query = `
        INSERT INTO charger_usage_history (charger_id, user_id, booking_id, session_start, status)
        VALUES ($1, $2, $3, CURRENT_TIMESTAMP, 'IN_PROGRESS')
        RETURNING *;
      `;

      const result = await db.query(query, [chargerId, userId, bookingId]);

      // Update charger status
      await this.updateCharger(chargerId, { status: 'BUSY' });

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to start charging session: ${error.message}`);
    }
  }

  /**
   * End a charging session
   */
  async endChargingSession(sessionId, energyConsumed, cost) {
    try {
      const query = `
        UPDATE charger_usage_history
        SET session_end = CURRENT_TIMESTAMP,
            status = 'COMPLETED',
            energy_consumed_kwh = $2,
            cost = $3,
            duration_minutes = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - session_start)) / 60
        WHERE id = $1
        RETURNING *;
      `;

      const result = await db.query(query, [sessionId, energyConsumed, cost]);

      if (result.rows.length === 0) {
        throw new Error('Session not found');
      }

      const session = result.rows[0];

      // Update charger status back to active
      await this.updateCharger(session.charger_id, { status: 'ACTIVE' });

      // Update usage statistics
      await this.updateUsageStats(session.charger_id);

      return session;
    } catch (error) {
      throw new Error(`Failed to end charging session: ${error.message}`);
    }
  }

  /**
   * Update charger usage statistics
   */
  async updateUsageStats(chargerId) {
    try {
      const statsQuery = `
        UPDATE chargers
        SET total_sessions = (
          SELECT COUNT(*) FROM charger_usage_history 
          WHERE charger_id = $1 AND status = 'COMPLETED'
        )
        WHERE id = $1;
      `;

      await db.query(statsQuery, [chargerId]);
    } catch (error) {
      console.error('Failed to update usage stats:', error.message);
    }
  }

  /**
   * Add charger review
   */
  async addReview({
    chargerId,
    reviewerId,
    bookingId,
    rating,
    reviewTitle,
    reviewText,
    cleanlinessRating,
    functionalityRating,
    locationRating,
  }) {
    try {
      const query = `
        INSERT INTO charger_reviews (
          charger_id, reviewer_id, booking_id, rating, review_title, review_text,
          cleanliness_rating, functionality_rating, location_rating, is_verified_purchase
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, true)
        RETURNING *;
      `;

      const result = await db.query(query, [
        chargerId,
        reviewerId,
        bookingId,
        rating,
        reviewTitle,
        reviewText,
        cleanlinessRating,
        functionalityRating,
        locationRating,
      ]);

      // Update charger rating
      await this.updateChargerRating(chargerId);

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to add review: ${error.message}`);
    }
  }

  /**
   * Update charger average rating
   */
  async updateChargerRating(chargerId) {
    try {
      const query = `
        UPDATE chargers
        SET avg_rating = (
          SELECT AVG(rating) FROM charger_reviews WHERE charger_id = $1
        ),
        total_reviews = (
          SELECT COUNT(*) FROM charger_reviews WHERE charger_id = $1
        )
        WHERE id = $1;
      `;

      await db.query(query, [chargerId]);
    } catch (error) {
      console.error('Failed to update charger rating:', error.message);
    }
  }

  /**
   * Get charger reviews
   */
  async getChargerReviews(chargerId, limit = 20, offset = 0) {
    try {
      const query = `
        SELECT cr.*, u.first_name, u.last_name, u.profile_image, u.average_rating
        FROM charger_reviews cr
        JOIN users u ON cr.reviewer_id = u.id
        WHERE cr.charger_id = $1
        ORDER BY cr.created_at DESC
        LIMIT $2 OFFSET $3;
      `;

      const result = await db.query(query, [chargerId, limit, offset]);

      return result.rows;
    } catch (error) {
      throw new Error(`Failed to get charger reviews: ${error.message}`);
    }
  }

  /**
   * Upload charger photos
   */
  async uploadPhoto(chargerId, photoUrl, displayOrder = 0, isPrimary = false) {
    try {
      const query = `
        INSERT INTO charger_photos (charger_id, photo_url, display_order, is_primary)
        VALUES ($1, $2, $3, $4)
        RETURNING *;
      `;

      const result = await db.query(query, [chargerId, photoUrl, displayOrder, isPrimary]);

      return result.rows[0];
    } catch (error) {
      throw new Error(`Failed to upload photo: ${error.message}`);
    }
  }

  /**
   * Get nearby chargers
   */
  async getNearbyChargers(latitude, longitude, radius = 50, limit = 20) {
    try {
      const query = `
        SELECT c.id, c.name, c.charger_type, c.power_kw, c.city,
               c.latitude, c.longitude, c.price_per_kwh, c.price_per_hour,
               c.status, c.avg_rating, c.total_reviews,
               (
                 6371 * acos(
                   cos(RADIANS($1)) * cos(RADIANS(c.latitude)) *
                   cos(RADIANS(c.longitude) - RADIANS($2)) +
                   sin(RADIANS($1)) * sin(RADIANS(c.latitude))
                 )
               ) AS distance_km
        FROM chargers c
        WHERE c.is_public = true AND c.status = 'ACTIVE'
        AND (
          6371 * acos(
            cos(RADIANS($1)) * cos(RADIANS(c.latitude)) *
            cos(RADIANS(c.longitude) - RADIANS($2)) +
            sin(RADIANS($1)) * sin(RADIANS(c.latitude))
          )
        ) <= $3
        ORDER BY distance_km ASC
        LIMIT $4;
      `;

      const result = await db.query(query, [latitude, longitude, radius, limit]);

      return result.rows;
    } catch (error) {
      throw new Error(`Failed to get nearby chargers: ${error.message}`);
    }
  }

  /**
   * Get charger statistics
   */
  async getChargerStats(chargerId) {
    try {
      const query = `
        SELECT 
          c.id,
          c.name,
          c.status,
          c.total_sessions,
          c.avg_rating,
          c.total_reviews,
          COUNT(DISTINCT cuh.id) AS completed_sessions,
          COALESCE(SUM(cuh.energy_consumed_kwh), 0) AS total_energy_kwh,
          COALESCE(SUM(cuh.cost), 0) AS total_revenue,
          AVG(cuh.duration_minutes) AS avg_session_minutes,
          (SELECT COUNT(*) FROM charger_usage_history 
           WHERE charger_id = c.id AND status = 'IN_PROGRESS') AS active_sessions
        FROM chargers c
        LEFT JOIN charger_usage_history cuh ON c.id = cuh.charger_id AND cuh.status = 'COMPLETED'
        WHERE c.id = $1
        GROUP BY c.id, c.name, c.status, c.total_sessions, c.avg_rating, c.total_reviews;
      `;

      const result = await db.query(query, [chargerId]);

      return result.rows[0] || null;
    } catch (error) {
      throw new Error(`Failed to get charger statistics: ${error.message}`);
    }
  }
}

export default new ChargerService();
