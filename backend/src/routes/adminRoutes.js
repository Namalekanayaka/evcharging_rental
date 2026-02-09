/**
 * Admin Routes
 * All routes require admin authentication
 */

const express = require('express');
const AdminController = require('../controllers/adminController');
const { authenticate, requireAdmin } = require('../middleware/auth');

function createAdminRoutes(db) {
  const router = express.Router();
  const adminController = new AdminController(db);

  // All routes require authentication and admin role
  router.use(authenticate);
  router.use(requireAdmin);

  // User Management
  router.get('/users', (req, res) => adminController.getUsers(req, res));
  router.post('/users/:userId/suspend', (req, res) => adminController.suspendUser(req, res));

  // Charger Management
  router.get('/chargers', (req, res) => adminController.getChargers(req, res));
  router.post('/chargers/:chargerId/approve', (req, res) => adminController.approveCharger(req, res));

  // Analytics
  router.get('/analytics/revenue', (req, res) => adminController.getRevenueAnalytics(req, res));
  router.get('/analytics/summary', (req, res) => adminController.getPlatformAnalytics(req, res));
  router.get('/analytics/top-chargers', (req, res) => adminController.getTopChargers(req, res));

  // Fraud & Disputes
  router.get('/fraud/cases', (req, res) => adminController.getFraudCases(req, res));
  router.post('/fraud/cases/:caseId/resolve', (req, res) => adminController.resolveFraudCase(req, res));

  // Promotions
  router.post('/promotions', (req, res) => adminController.createPromotion(req, res));
  router.get('/promotions', (req, res) => adminController.getPromotions(req, res));

  return router;
}

module.exports = createAdminRoutes;
