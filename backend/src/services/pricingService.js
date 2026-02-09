/**
 * Pricing Service
 * Manages pricing tiers, subscription packages, and dynamic pricing
 */

const db = require('../database/connection');

class PricingService {
  /**
   * Get all pricing packages
   */
  async getPricingPackages() {
    const result = await db.query(`
      SELECT * FROM pricing_packages
      WHERE is_active = true
      ORDER BY tier ASC
    `);
    return result.rows;
  }

  /**
   * Get package by ID
   */
  async getPackageById(packageId) {
    const result = await db.query(
      'SELECT * FROM pricing_packages WHERE id = $1 AND is_active = true',
      [packageId]
    );
    return result.rows[0];
  }

  /**
   * Get user's current package
   */
  async getUserPackage(userId) {
    const result = await db.query(
      `SELECT sp.*, pp.name, pp.tier, pp.monthly_price, pp.annual_price, 
              pp.features, pp.commission_rate
       FROM user_subscriptions sp
       JOIN pricing_packages pp ON sp.package_id = pp.id
       WHERE sp.user_id = $1 AND sp.is_active = true
       ORDER BY sp.created_at DESC LIMIT 1`,
      [userId]
    );
    return result.rows[0];
  }

  /**
   * Subscribe user to a package
   */
  async subscribeToPackage(userId, packageId, billingCycle) {
    const pckg = await this.getPackageById(packageId);
    if (!pckg) throw new Error('Package not found');

    const billingAmount = billingCycle === 'annual' ? pckg.annual_price : pckg.monthly_price;
    const nextBillingDate = new Date();
    nextBillingDate.setMonth(nextBillingDate.getMonth() + (billingCycle === 'annual' ? 12 : 1));

    const result = await db.query(
      `INSERT INTO user_subscriptions 
       (user_id, package_id, billing_cycle, amount, next_billing_date, is_active)
       VALUES ($1, $2, $3, $4, $5, true)
       RETURNING *`,
      [userId, packageId, billingCycle, billingAmount, nextBillingDate]
    );

    return result.rows[0];
  }

  /**
   * Cancel subscription
   */
  async cancelSubscription(userId) {
    const result = await db.query(
      `UPDATE user_subscriptions 
       SET is_active = false, cancelled_at = NOW()
       WHERE user_id = $1 AND is_active = true
       RETURNING *`,
      [userId]
    );
    return result.rows[0];
  }

  /**
   * Calculate dynamic pricing for a charger
   * Based on: location demand, time of day, battery level, charger type
   */
  async calculateDynamicPrice(chargerId, demandLevel = 'medium') {
    const charger = await db.query(
      'SELECT price_per_hour FROM chargers WHERE id = $1',
      [chargerId]
    );

    if (!charger.rows[0]) throw new Error('Charger not found');

    const basePrice = charger.rows[0].price_per_hour;
    const demandMultiplier = {
      low: 0.8,
      medium: 1.0,
      high: 1.25,
      peak: 1.5
    }[demandLevel] || 1.0;

    const dynamicPrice = basePrice * demandMultiplier;

    return {
      basePrice,
      demandLevel,
      demandMultiplier,
      dynamicPrice: Math.round(dynamicPrice * 100) / 100
    };
  }

  /**
   * Get pricing history for a charger (for analytics)
   */
  async getPricingHistory(chargerId, days = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const result = await db.query(
      `SELECT 
         DATE(created_at) as date,
         AVG(price_applied) as avg_price,
         MAX(price_applied) as max_price,
         MIN(price_applied) as min_price,
         COUNT(*) as bookings_count
       FROM bookings
       WHERE charger_id = $1 AND created_at > $2
       GROUP BY DATE(created_at)
       ORDER BY date DESC`,
      [chargerId, startDate]
    );

    return result.rows;
  }

  /**
   * Get commission breakdown for charger owner
   */
  async getCommissionBreakdown(userId, month = new Date().getMonth() + 1, year = new Date().getFullYear()) {
    const result = await db.query(
      `SELECT 
         c.id as charger_id,
         c.name as charger_name,
         SUM(b.price_applied) as total_revenue,
         pp.commission_rate,
         (SUM(b.price_applied) * pp.commission_rate / 100) as platform_commission,
         (SUM(b.price_applied) * (100 - pp.commission_rate) / 100) as owner_earnings,
         COUNT(b.id) as bookings_count
       FROM bookings b
       JOIN chargers c ON b.charger_id = c.id
       JOIN user_subscriptions us ON c.owner_id = us.user_id
       JOIN pricing_packages pp ON us.package_id = pp.id
       WHERE c.owner_id = $1 
         AND EXTRACT(MONTH FROM b.completed_at) = $2
         AND EXTRACT(YEAR FROM b.completed_at) = $3
       GROUP BY c.id, c.name, pp.commission_rate`,
      [userId, month, year]
    );

    return result.rows;
  }

  /**
   * Create custom pricing rule for specific charger
   */
  async createPricingRule(chargerId, ruleName, conditions, priceModifier) {
    const result = await db.query(
      `INSERT INTO pricing_rules 
       (charger_id, rule_name, conditions, price_modifier, is_active)
       VALUES ($1, $2, $3, $4, true)
       RETURNING *`,
      [chargerId, ruleName, JSON.stringify(conditions), priceModifier]
    );
    return result.rows[0];
  }

  /**
   * Get active pricing rules for a charger
   */
  async getPricingRules(chargerId) {
    const result = await db.query(
      `SELECT * FROM pricing_rules 
       WHERE charger_id = $1 AND is_active = true`,
      [chargerId]
    );
    return result.rows;
  }

  /**
   * Get subscription usage for analytics
   */
  async getSubscriptionAnalytics(startDate, endDate) {
    const result = await db.query(
      `SELECT 
         pp.name,
         pp.tier,
         COUNT(DISTINCT us.user_id) as subscriber_count,
         SUM(us.amount) as total_revenue,
         AVG(us.amount) as avg_subscription_value
       FROM user_subscriptions us
       JOIN pricing_packages pp ON us.package_id = pp.id
       WHERE us.created_at BETWEEN $1 AND $2 AND us.is_active = true
       GROUP BY pp.name, pp.tier
       ORDER BY pp.tier ASC`,
      [startDate, endDate]
    );
    return result.rows;
  }
}

module.exports = new PricingService();
