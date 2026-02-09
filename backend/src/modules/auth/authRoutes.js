import express from "express";
import {
  register,
  verifyEmailOTP,
  verifyPhoneOTP,
  login,
  resendOTP,
  refreshToken,
  logout,
  changePassword,
  requestPasswordReset,
  resetPassword,
  send2FA,
  verify2FA,
  getSessions,
  terminateSession,
} from "./authController.js";
import {
  authMiddleware,
  optionalAuth,
  updateSessionActivity,
} from "../../middleware/authMiddleware.js";
import {
  loginRateLimit,
  otpRateLimit,
  passwordResetRateLimit,
} from "../../middleware/rateLimitMiddleware.js";

const router = express.Router();

/**
 * Public routes (no authentication required)
 */

// Register new user
router.post("/register", otpRateLimit, register);

// Verify OTP (email or phone)
router.post("/verify-email-otp", otpRateLimit, verifyEmailOTP);
router.post("/verify-phone-otp", otpRateLimit, verifyPhoneOTP);

// Login
router.post("/login", loginRateLimit, login);

// Resend OTP
router.post("/resend-otp", otpRateLimit, resendOTP);

// Password reset flow
router.post(
  "/request-password-reset",
  passwordResetRateLimit,
  requestPasswordReset,
);
router.post("/reset-password", passwordResetRateLimit, resetPassword);

/**
 * Protected routes (authentication required)
 */

// Session management middleware
router.use(authMiddleware, updateSessionActivity);

// Refresh token
router.post("/refresh-token", refreshToken);

// Logout
router.post("/logout", logout);

// Password management
router.post("/change-password", changePassword);

// Two-factor authentication
router.post("/send-2fa", send2FA);
router.post("/verify-2fa", verify2FA);

// Session management
router.get("/sessions", getSessions);
router.delete("/sessions/:sessionId", terminateSession);

export default router;
