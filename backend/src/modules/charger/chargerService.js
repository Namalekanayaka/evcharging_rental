import db from "../../config/database.js";
import { calculateDistance } from "../../utils/helpers.js";

export class ChargerService {
  // Create charger (owner)
  async createCharger(ownerId, data) {
    try {
      const {
        name,
        description,
        type,
        address,
        latitude,
        longitude,
        pricePerHour,
        connectorTypes,
        maxWattage,
        availability,
        images,
      } = data;

      const charger = await db.one(
        `INSERT INTO chargers 
         (owner_id, name, description, type, address, latitude, longitude, 
          price_per_hour, connector_types, max_wattage, availability, images, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, 'active')
         RETURNING id, owner_id, name, description, type, address, latitude, longitude,
                   price_per_hour, connector_types, max_wattage, availability, status, created_at`,
        [
          ownerId,
          name,
          description,
          type,
          address,
          latitude,
          longitude,
          pricePerHour,
          JSON.stringify(connectorTypes),
          maxWattage,
          JSON.stringify(availability),
          JSON.stringify(images),
        ],
      );

      return charger;
    } catch (error) {
      throw error;
    }
  }

  // Update charger
  async updateCharger(chargerId, ownerId, data) {
    try {
      const { name, description, pricePerHour, availability, status } = data;

      const charger = await db.one(
        `UPDATE chargers
         SET name = COALESCE($1, name),
             description = COALESCE($2, description),
             price_per_hour = COALESCE($3, price_per_hour),
             availability = COALESCE($4, availability),
             status = COALESCE($5, status),
             updated_at = NOW()
         WHERE id = $6 AND owner_id = $7
         RETURNING *`,
        [
          name,
          description,
          pricePerHour,
          availability,
          status,
          chargerId,
          ownerId,
        ],
      );

      if (!charger) {
        throw new Error("Charger not found or unauthorized");
      }

      return charger;
    } catch (error) {
      throw error;
    }
  }

  // Get charger by ID
  async getChargerById(chargerId) {
    try {
      const charger = await db.one(
        `SELECT c.*, 
                (SELECT AVG(rating) FROM reviews WHERE charger_id = c.id) as average_rating,
                (SELECT COUNT(*) FROM reviews WHERE charger_id = c.id) as total_reviews,
                (SELECT COUNT(*) FROM bookings WHERE charger_id = c.id AND status = 'completed') as total_bookings,
                json_build_object('id', u.id, 'name', CONCAT(u.first_name, ' ', u.last_name), 'rating', u.average_rating) as owner
         FROM chargers c
         JOIN users u ON c.owner_id = u.id
         WHERE c.id = $1`,
        [chargerId],
      );
      return charger;
    } catch (error) {
      throw error;
    }
  }

  // Search chargers
  async searchChargers(filters) {
    try {
      let query = `SELECT c.*, 
                          (SELECT AVG(rating) FROM reviews WHERE charger_id = c.id) as average_rating,
                          (SELECT COUNT(*) FROM reviews WHERE charger_id = c.id) as total_reviews
                   FROM chargers c
                   WHERE c.status = 'active'`;
      const params = [];

      // Location search with distance
      if (filters.latitude && filters.longitude) {
        params.push(filters.latitude);
        params.push(filters.longitude);
        params.push(filters.radius || 5); // Default 5 km
        query += ` AND ST_DWithin(
                    ST_MakePoint(c.longitude, c.latitude)::geography,
                    ST_MakePoint($2, $1)::geography,
                    $3 * 1000
                  )`;
      }

      if (filters.type) {
        params.push(filters.type);
        query += ` AND c.type = $${params.length}`;
      }

      if (filters.minPrice !== undefined && filters.maxPrice !== undefined) {
        params.push(filters.minPrice);
        params.push(filters.maxPrice);
        query += ` AND c.price_per_hour BETWEEN $${params.length - 1} AND $${params.length}`;
      }

      if (filters.connectorType) {
        query += ` AND c.connector_types @> $${params.length + 1}`;
        params.push(JSON.stringify([filters.connectorType]));
      }

      if (filters.minRating) {
        params.push(filters.minRating);
        query += ` AND (SELECT AVG(rating) FROM reviews WHERE charger_id = c.id) >= $${params.length}`;
      }

      query += " ORDER BY c.created_at DESC LIMIT 100";

      const chargers = await db.query(query, params);
      return chargers;
    } catch (error) {
      throw error;
    }
  }

  // Get owner's chargers
  async getOwnerChargers(ownerId, limit = 20, offset = 0) {
    try {
      const chargers = await db.query(
        `SELECT c.*,
                (SELECT AVG(rating) FROM reviews WHERE charger_id = c.id) as average_rating,
                (SELECT COUNT(*) FROM reviews WHERE charger_id = c.id) as total_reviews
         FROM chargers c
         WHERE c.owner_id = $1
         ORDER BY c.created_at DESC
         LIMIT $2 OFFSET $3`,
        [ownerId, limit, offset],
      );
      return chargers;
    } catch (error) {
      throw error;
    }
  }

  // Delete charger
  async deleteCharger(chargerId, ownerId) {
    try {
      const result = await db.result(
        "DELETE FROM chargers WHERE id = $1 AND owner_id = $2",
        [chargerId, ownerId],
      );

      if (result.rowCount === 0) {
        throw new Error("Charger not found or unauthorized");
      }

      return { message: "Charger deleted successfully" };
    } catch (error) {
      throw error;
    }
  }

  // Get charger availability
  async getChargerAvailability(chargerId, date) {
    try {
      const availability = await db.query(
        `SELECT * FROM charger_availability 
         WHERE charger_id = $1 AND date = $2
         ORDER BY time_slot`,
        [chargerId, date],
      );
      return availability;
    } catch (error) {
      throw error;
    }
  }

  // ========================= Advanced Charger Features =========================

  // Set availability schedule
  async setAvailability(chargerId, dayOfWeek, startTime, endTime, isAvailable = true) {
    try {
      const availability = await db.one(
        `INSERT INTO charger_availability (charger_id, day_of_week, start_time, end_time, is_available)
         VALUES ($1, $2, $3, $4, $5)
         ON CONFLICT (charger_id, day_of_week) 
         DO UPDATE SET start_time = $3, end_time = $4, is_available = $5
         RETURNING *`,
        [chargerId, dayOfWeek, startTime, endTime, isAvailable],
      );
      return availability;
    } catch (error) {
      throw error;
    }
  }

  // Get usage history
  async getUsageHistory(chargerId, limit = 50, offset = 0) {
    try {
      const history = await db.query(
        `SELECT cuh.*, u.first_name, u.last_name, u.email
         FROM charger_usage_history cuh
         JOIN users u ON cuh.user_id = u.id
         WHERE cuh.charger_id = $1
         ORDER BY cuh.session_start DESC
         LIMIT $2 OFFSET $3`,
        [chargerId, limit, offset],
      );
      return history;
    } catch (error) {
      throw error;
    }
  }

  // Start charging session
  async startChargingSession(chargerId, userId, bookingId = null) {
    try {
      const session = await db.one(
        `INSERT INTO charger_usage_history (charger_id, user_id, booking_id, session_start, status)
         VALUES ($1, $2, $3, CURRENT_TIMESTAMP, 'IN_PROGRESS')
         RETURNING *`,
        [chargerId, userId, bookingId],
      );

      // Update charger status to BUSY
      await db.result(
        `UPDATE chargers SET status = 'BUSY' WHERE id = $1`,
        [chargerId],
      );

      return session;
    } catch (error) {
      throw error;
    }
  }

  // End charging session
  async endChargingSession(sessionId, energyConsumed, cost) {
    try {
      const session = await db.one(
        `UPDATE charger_usage_history
         SET session_end = CURRENT_TIMESTAMP,
             status = 'COMPLETED',
             energy_consumed_kwh = $2,
             cost = $3,
             duration_minutes = EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - session_start)) / 60
         WHERE id = $1
         RETURNING *`,
        [sessionId, energyConsumed, cost],
      );

      // Update charger status back to ACTIVE
      await db.result(
        `UPDATE chargers SET status = 'ACTIVE' WHERE id = $1`,
        [session.charger_id],
      );

      // Update usage statistics
      await this.updateUsageStats(session.charger_id);

      return session;
    } catch (error) {
      throw error;
    }
  }

  // Update charger usage statistics
  async updateUsageStats(chargerId) {
    try {
      await db.result(
        `UPDATE chargers
         SET total_sessions = (
           SELECT COUNT(*) FROM charger_usage_history 
           WHERE charger_id = $1 AND status = 'COMPLETED'
         )
         WHERE id = $1`,
        [chargerId],
      );
    } catch (error) {
      console.error("Failed to update usage stats:", error.message);
    }
  }

  // Add charger review
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
      const review = await db.one(
        `INSERT INTO charger_reviews (
           charger_id, reviewer_id, booking_id, rating, review_title, review_text,
           cleanliness_rating, functionality_rating, location_rating, is_verified_purchase
         ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, true)
         RETURNING *`,
        [
          chargerId,
          reviewerId,
          bookingId,
          rating,
          reviewTitle,
          reviewText,
          cleanlinessRating,
          functionalityRating,
          locationRating,
        ],
      );

      // Update charger rating
      await this.updateChargerRating(chargerId);

      return review;
    } catch (error) {
      throw error;
    }
  }

  // Update charger average rating
  async updateChargerRating(chargerId) {
    try {
      await db.result(
        `UPDATE chargers
         SET avg_rating = (
           SELECT AVG(rating) FROM charger_reviews WHERE charger_id = $1
         ),
         total_reviews = (
           SELECT COUNT(*) FROM charger_reviews WHERE charger_id = $1
         )
         WHERE id = $1`,
        [chargerId],
      );
    } catch (error) {
      console.error("Failed to update charger rating:", error.message);
    }
  }

  // Get charger reviews
  async getChargerReviews(chargerId, limit = 20, offset = 0) {
    try {
      const reviews = await db.query(
        `SELECT cr.*, u.first_name, u.last_name, u.profile_image, u.average_rating
         FROM charger_reviews cr
         JOIN users u ON cr.reviewer_id = u.id
         WHERE cr.charger_id = $1
         ORDER BY cr.created_at DESC
         LIMIT $2 OFFSET $3`,
        [chargerId, limit, offset],
      );
      return reviews;
    } catch (error) {
      throw error;
    }
  }

  // Get nearby chargers (within radius)
  async getNearbyChargers(latitude, longitude, radius = 50, limit = 20) {
    try {
      const chargers = await db.query(
        `SELECT c.id, c.name, c.type, c.max_wattage, c.city,
                c.latitude, c.longitude, c.price_per_hour,
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
         LIMIT $4`,
        [latitude, longitude, radius, limit],
      );
      return chargers;
    } catch (error) {
      throw error;
    }
  }

  // Get charger statistics
  async getChargerStats(chargerId) {
    try {
      const stats = await db.oneOrNone(
        `SELECT 
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
         GROUP BY c.id, c.name, c.status, c.total_sessions, c.avg_rating, c.total_reviews`,
        [chargerId],
      );
      return stats;
    } catch (error) {
      throw error;
    }
  }

  // Upload charger photo
  async uploadPhoto(chargerId, photoUrl, displayOrder = 0, isPrimary = false) {
    try {
      const photo = await db.one(
        `INSERT INTO charger_photos (charger_id, photo_url, display_order, is_primary)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [chargerId, photoUrl, displayOrder, isPrimary],
      );
      return photo;
    } catch (error) {
      throw error;
    }
  }

}

export default new ChargerService();
