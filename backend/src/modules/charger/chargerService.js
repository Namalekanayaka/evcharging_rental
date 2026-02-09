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
}

export default new ChargerService();
