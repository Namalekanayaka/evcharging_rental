import express from "express";
import authRoutes from "../modules/auth/authRoutes.js";
import userRoutes from "../modules/user/userRoutes.js";
import chargerRoutes from "../modules/charger/chargerRoutes.js";
import bookingRoutes from "../modules/booking/bookingRoutes.js";
import sessionRoutes from "../modules/session/sessionRoutes.js";
import searchRoutes from "../modules/search/searchRoutes.js";
import paymentRoutes from "../modules/payment/paymentRoutes.js";
import walletRoutes from "../modules/wallet/walletRoutes.js";
import reviewRoutes from "../modules/review/reviewRoutes.js";
import pricingRoutes from "../modules/pricing/pricingRoutes.js";
import aiRoutes from "../modules/ai/aiRoutes.js";
import adminRoutes from "../modules/admin/adminRoutes.js";

const router = express.Router();

// API routes
router.use("/auth", authRoutes);
router.use("/users", userRoutes);
router.use("/chargers", chargerRoutes);
router.use("/bookings", bookingRoutes);
router.use("/sessions", sessionRoutes);
router.use("/search", searchRoutes);
router.use("/payments", paymentRoutes);
router.use("/wallet", walletRoutes);
router.use("/reviews", reviewRoutes);
router.use("/pricing", pricingRoutes);
router.use("/ai", aiRoutes);
router.use("/admin", adminRoutes);

export default router;
