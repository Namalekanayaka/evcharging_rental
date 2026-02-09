/**
 * Admin Controller
 * Handles admin dashboard API requests
 */

const AdminService = require('../services/adminService');

class AdminController {
  constructor(db) {
    this.adminService = new AdminService(db);
  }

  /**
   * Get all users
   * GET /api/admin/users
   */
  async getUsers(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 20;
      const offset = parseInt(req.query.offset) || 0;
      const filters = {
        isActive: req.query.isActive !== undefined ? req.query.isActive === 'true' : undefined,
        email: req.query.email,
        createdAfter: req.query.createdAfter,
      };

      const users = await this.adminService.getAllUsers(limit, offset, filters);

      res.json({
        success: true,
        data: users,
        count: users.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Suspend user
   * POST /api/admin/users/:userId/suspend
   */
  async suspendUser(req, res) {
    try {
      const { userId } = req.params;
      const { suspend = true } = req.body;

      const user = await this.adminService.toggleUserSuspension(userId, suspend);

      res.json({
        success: true,
        data: user,
        message: suspend ? 'User suspended' : 'User activated',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get charger management data
   * GET /api/admin/chargers
   */
  async getChargers(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 20;
      const offset = parseInt(req.query.offset) || 0;
      const filters = {
        isApproved: req.query.isApproved !== undefined ? req.query.isApproved === 'true' : undefined,
        isActive: req.query.isActive !== undefined ? req.query.isActive === 'true' : undefined,
        chargerType: req.query.chargerType,
      };

      const chargers = await this.adminService.getChargerManagement(limit, offset, filters);

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
   * Approve charger
   * POST /api/admin/chargers/:chargerId/approve
   */
  async approveCharger(req, res) {
    try {
      const { chargerId } = req.params;
      const { approved = true, reason = '' } = req.body;

      const charger = await this.adminService.approveCharger(chargerId, approved, reason);

      res.json({
        success: true,
        data: charger,
        message: approved ? 'Charger approved' : 'Charger rejected',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get revenue analytics
   * GET /api/admin/analytics/revenue
   */
  async getRevenueAnalytics(req, res) {
    try {
      const { startDate, endDate } = req.query;

      if (!startDate || !endDate) {
        return res.status(400).json({
          success: false,
          error: 'startDate and endDate are required',
        });
      }

      const analytics = await this.adminService.getRevenueAnalytics(startDate, endDate);

      res.json({
        success: true,
        data: analytics,
        count: analytics.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get platform analytics summary
   * GET /api/admin/analytics/summary
   */
  async getPlatformAnalytics(req, res) {
    try {
      const summary = await this.adminService.getPlatformAnalytics();

      res.json({
        success: true,
        data: summary,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get fraud cases
   * GET /api/admin/fraud/cases
   */
  async getFraudCases(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 10;
      const offset = parseInt(req.query.offset) || 0;

      const cases = await this.adminService.getFraudCases(limit, offset);

      res.json({
        success: true,
        data: cases,
        count: cases.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Resolve fraud case
   * POST /api/admin/fraud/cases/:caseId/resolve
   */
  async resolveFraudCase(req, res) {
    try {
      const { caseId } = req.params;
      const { resolution, notes = '' } = req.body;

      if (!resolution) {
        return res.status(400).json({
          success: false,
          error: 'resolution is required',
        });
      }

      const result = await this.adminService.resolveFraudCase(caseId, resolution, notes);

      res.json({
        success: true,
        data: result,
        message: 'Fraud case resolved',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Create promotion
   * POST /api/admin/promotions
   */
  async createPromotion(req, res) {
    try {
      const { title, description, discountPercentage, startDate, endDate, maxUses, code } = req.body;

      if (!title || !code || !discountPercentage || !startDate || !endDate) {
        return res.status(400).json({
          success: false,
          error: 'title, code, discountPercentage, startDate, and endDate are required',
        });
      }

      const promotion = await this.adminService.createPromotion({
        title,
        description,
        discountPercentage,
        startDate,
        endDate,
        maxUses,
        code,
      });

      res.json({
        success: true,
        data: promotion,
        message: 'Promotion created',
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get active promotions
   * GET /api/admin/promotions
   */
  async getPromotions(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 20;
      const offset = parseInt(req.query.offset) || 0;

      const promotions = await this.adminService.getPromotions(limit, offset);

      res.json({
        success: true,
        data: promotions,
        count: promotions.length,
      });
    } catch (error) {
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  }

  /**
   * Get top chargers
   * GET /api/admin/analytics/top-chargers
   */
  async getTopChargers(req, res) {
    try {
      const limit = parseInt(req.query.limit) || 10;

      const chargers = await this.adminService.getTopChargers(limit);

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
}

module.exports = AdminController;
