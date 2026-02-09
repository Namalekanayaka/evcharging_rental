/**
 * Pricing Controller
 * Handles API requests for pricing packages and subscriptions
 */

const pricingService = require("../services/pricingService");
const {
  validateRequest,
  sendResponse,
  handleError,
} = require("../utils/apiHelper");

class PricingController {
  /**
   * Get all pricing packages
   * GET /api/pricing/packages
   */
  async getPackages(req, res) {
    try {
      const packages = await pricingService.getPricingPackages();
      sendResponse(res, 200, "Pricing packages fetched successfully", packages);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get user's current subscription
   * GET /api/pricing/subscription
   */
  async getUserSubscription(req, res) {
    try {
      validateRequest(req, "user");
      const subscription = await pricingService.getUserPackage(req.user.id);
      sendResponse(
        res,
        200,
        "Subscription fetched successfully",
        subscription || null,
      );
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Subscribe to a package
   * POST /api/pricing/subscribe
   * Body: { packageId, billingCycle: 'monthly' | 'annual' }
   */
  async subscribeToPackage(req, res) {
    try {
      validateRequest(req, "user", "body");
      const { packageId, billingCycle = "monthly" } = req.body;

      if (!packageId) throw new Error("Package ID is required");
      if (!["monthly", "annual"].includes(billingCycle))
        throw new Error("Invalid billing cycle");

      const subscription = await pricingService.subscribeToPackage(
        req.user.id,
        packageId,
        billingCycle,
      );
      sendResponse(
        res,
        201,
        "Successfully subscribed to package",
        subscription,
      );
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Cancel subscription
   * POST /api/pricing/cancel-subscription
   */
  async cancelSubscription(req, res) {
    try {
      validateRequest(req, "user");
      const subscription = await pricingService.cancelSubscription(req.user.id);
      sendResponse(
        res,
        200,
        "Subscription cancelled successfully",
        subscription,
      );
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Calculate dynamic price for a charger
   * GET /api/pricing/dynamic-price/:chargerId?demandLevel=high
   */
  async getDynamicPrice(req, res) {
    try {
      validateRequest(req, "params");
      const { chargerId } = req.params;
      const { demandLevel = "medium" } = req.query;

      if (!chargerId) throw new Error("Charger ID is required");

      const pricing = await pricingService.calculateDynamicPrice(
        parseInt(chargerId),
        demandLevel,
      );
      sendResponse(res, 200, "Dynamic price calculated", pricing);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get pricing history for charger
   * GET /api/pricing/history/:chargerId?days=30
   */
  async getPricingHistory(req, res) {
    try {
      validateRequest(req, "user", "params");
      const { chargerId } = req.params;
      const { days = 30 } = req.query;

      if (!chargerId) throw new Error("Charger ID is required");

      const history = await pricingService.getPricingHistory(
        parseInt(chargerId),
        parseInt(days),
      );
      sendResponse(res, 200, "Pricing history fetched", history);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get commission breakdown for charger owner
   * GET /api/pricing/commission?month=2&year=2026
   */
  async getCommissionBreakdown(req, res) {
    try {
      validateRequest(req, "user");
      const { month, year } = req.query;

      const breakdown = await pricingService.getCommissionBreakdown(
        req.user.id,
        month ? parseInt(month) : new Date().getMonth() + 1,
        year ? parseInt(year) : new Date().getFullYear(),
      );

      sendResponse(res, 200, "Commission breakdown fetched", breakdown);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get subscription analytics (admin only)
   * GET /api/pricing/analytics?startDate=2026-01-01&endDate=2026-01-31
   */
  async getAnalytics(req, res) {
    try {
      validateRequest(req, "user", "query");
      // Check admin role here if needed
      const { startDate, endDate } = req.query;

      const analytics = await pricingService.getSubscriptionAnalytics(
        new Date(startDate),
        new Date(endDate),
      );

      sendResponse(res, 200, "Analytics fetched", analytics);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Create pricing rule for charger
   * POST /api/pricing/rules
   * Body: { chargerId, ruleName, conditions: {}, priceModifier }
   */
  async createPricingRule(req, res) {
    try {
      validateRequest(req, "user", "body");
      const { chargerId, ruleName, conditions, priceModifier } = req.body;

      if (!chargerId || !ruleName || !priceModifier) {
        throw new Error("ChargerId, ruleName, and priceModifier are required");
      }

      const rule = await pricingService.createPricingRule(
        chargerId,
        ruleName,
        conditions,
        priceModifier,
      );
      sendResponse(res, 201, "Pricing rule created successfully", rule);
    } catch (error) {
      handleError(res, error);
    }
  }

  /**
   * Get pricing rules for charger
   * GET /api/pricing/rules/:chargerId
   */
  async getPricingRules(req, res) {
    try {
      validateRequest(req, "params");
      const { chargerId } = req.params;

      if (!chargerId) throw new Error("Charger ID is required");

      const rules = await pricingService.getPricingRules(parseInt(chargerId));
      sendResponse(res, 200, "Pricing rules fetched", rules);
    } catch (error) {
      handleError(res, error);
    }
  }
}

module.exports = new PricingController();
