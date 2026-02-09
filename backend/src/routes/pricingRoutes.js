/**
 * Pricing Routes
 * Routes for pricing packages, subscriptions, and billing
 */

const express = require('express');
const router = express.Router();
const pricingController = require('../controllers/pricingController');
const { authenticate } = require('../middleware/authMiddleware');

// Public routes
router.get('/packages', pricingController.getPackages);

// Protected routes (require authentication)
router.get('/subscription', authenticate, pricingController.getUserSubscription);
router.post('/subscribe', authenticate, pricingController.subscribeToPackage);
router.post('/cancel-subscription', authenticate, pricingController.cancelSubscription);
router.get('/dynamic-price/:chargerId', authenticate, pricingController.getDynamicPrice);
router.get('/history/:chargerId', authenticate, pricingController.getPricingHistory);
router.get('/commission', authenticate, pricingController.getCommissionBreakdown);
router.post('/rules', authenticate, pricingController.createPricingRule);
router.get('/rules/:chargerId', authenticate, pricingController.getPricingRules);

// Admin routes
router.get('/analytics', authenticate, pricingController.getAnalytics);

module.exports = router;
