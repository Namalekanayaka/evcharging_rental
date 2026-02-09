/**
 * AI Routes
 */

const express = require('express');
const AIController = require('../controllers/aiController');
const { authenticate } = require('../middleware/auth');

function createAIRoutes(db) {
  const router = express.Router();
  const aiController = new AIController(db);

  // Public routes
  router.post('/battery-range', (req, res) => aiController.predictBatteryRange(req, res));
  router.post('/nearest-chargers', (req, res) => aiController.findNearestChargers(req, res));
  router.get('/demand-pricing/:chargerId', (req, res) => aiController.predictDemandPricing(req, res));
  router.post('/optimize-route', (req, res) => aiController.optimizeRoute(req, res));

  // Protected routes
  router.get('/recommendations', authenticate, (req, res) => aiController.getRecommendations(req, res));

  return router;
}

module.exports = createAIRoutes;
