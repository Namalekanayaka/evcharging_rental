import db from "../../config/database.js";

export class PricingService {
  // Get pricing packages
  async getPricingPackages() {
    try {
      const packages = await db.query(
        "SELECT * FROM pricing_packages ORDER BY created_at DESC",
      );
      return packages;
    } catch (error) {
      throw error;
    }
  }

  // Get package by ID
  async getPackageById(packageId) {
    try {
      const pkg = await db.one("SELECT * FROM pricing_packages WHERE id = $1", [
        packageId,
      ]);
      return pkg;
    } catch (error) {
      throw error;
    }
  }

  // Create pricing package (admin)
  async createPackage(data) {
    try {
      const { name, description, basePrice, hourlyRate, benefits } = data;

      const pkg = await db.one(
        `INSERT INTO pricing_packages (name, description, base_price, hourly_rate, benefits)
         VALUES ($1, $2, $3, $4, $5)
         RETURNING *`,
        [name, description, basePrice, hourlyRate, JSON.stringify(benefits)],
      );

      return pkg;
    } catch (error) {
      throw error;
    }
  }

  // Update pricing package (admin)
  async updatePackage(packageId, data) {
    try {
      const { name, description, basePrice, hourlyRate, benefits } = data;

      const pkg = await db.one(
        `UPDATE pricing_packages 
         SET name = COALESCE($1, name),
             description = COALESCE($2, description),
             base_price = COALESCE($3, base_price),
             hourly_rate = COALESCE($4, hourly_rate),
             benefits = COALESCE($5, benefits),
             updated_at = NOW()
         WHERE id = $6
         RETURNING *`,
        [
          name,
          description,
          basePrice,
          hourlyRate,
          JSON.stringify(benefits),
          packageId,
        ],
      );

      return pkg;
    } catch (error) {
      throw error;
    }
  }

  // Calculate booking price
  async calculateBookingPrice(chargerId, duration, discount = 0) {
    try {
      const charger = await db.one(
        "SELECT price_per_hour FROM chargers WHERE id = $1",
        [chargerId],
      );

      if (!charger) {
        throw new Error("Charger not found");
      }

      const basePrice = charger.price_per_hour * duration;
      const discountAmount = (basePrice * discount) / 100;
      const totalPrice = basePrice - discountAmount;

      return {
        basePrice,
        discount,
        discountAmount,
        totalPrice,
        duration,
      };
    } catch (error) {
      throw error;
    }
  }

  // Get pricing statistics
  async getPricingStats() {
    try {
      const stats = await db.one(
        `SELECT 
           (SELECT AVG(price_per_hour) FROM chargers WHERE status = 'active') as avg_charger_price,
           (SELECT MIN(price_per_hour) FROM chargers WHERE status = 'active') as min_charger_price,
           (SELECT MAX(price_per_hour) FROM chargers WHERE status = 'active') as max_charger_price,
           (SELECT AVG(CAST(total_amount AS DECIMAL)) FROM bookings WHERE status = 'completed') as avg_booking_amount,
           (SELECT COUNT(*) FROM chargers WHERE status = 'active') as total_active_chargers
         FROM pricing_packages LIMIT 1`,
      );
      return stats;
    } catch (error) {
      throw error;
    }
  }
}

export default new PricingService();
