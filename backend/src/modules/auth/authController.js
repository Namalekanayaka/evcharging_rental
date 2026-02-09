import jwt from "jsonwebtoken";
import { jwtConfig } from "../../config/jwt.js";
import authService from "./authService.js";
import { asyncHandler, ApiError } from "../../utils/errors.js";

/**
 * Register new user
 * POST /api/auth/register
 */
export const register = asyncHandler(async (req, res, next) => {
  try {
    const {
      email,
      phone,
      password,
      confirmPassword,
      firstName,
      lastName,
      userType,
    } = req.body;

    // Validation
    if (!email || !phone || !password || !firstName || !lastName || !userType) {
      return next(new ApiError(400, "All fields are required"));
    }

    if (password !== confirmPassword) {
      return next(new ApiError(400, "Passwords do not match"));
    }

    if (password.length < 8) {
      return next(
        new ApiError(400, "Password must be at least 8 characters long"),
      );
    }

    const result = await authService.register({
      email,
      phone,
      password,
      firstName,
      lastName,
      userType,
    });

    res.status(201).json({
      success: true,
      data: result,
      message: "Registration successful. OTP sent to your email.",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Verify email OTP
 * POST /api/auth/verify-email-otp
 */
export const verifyEmailOTP = asyncHandler(async (req, res, next) => {
  try {
    const { userId, otp } = req.body;

    if (!userId || !otp) {
      return next(new ApiError(400, "User ID and OTP are required"));
    }

    const result = await authService.verifyEmailOTP(userId, otp);

    res.status(200).json({
      success: true,
      data: result,
      message: "Email verified successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Verify phone OTP
 * POST /api/auth/verify-phone-otp
 */
export const verifyPhoneOTP = asyncHandler(async (req, res, next) => {
  try {
    const { userId, otp } = req.body;

    if (!userId || !otp) {
      return next(new ApiError(400, "User ID and OTP are required"));
    }

    const result = await authService.verifyPhoneOTP(userId, otp);

    res.status(200).json({
      success: true,
      data: result,
      message: "Phone verified successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Enhanced login with session creation
 * POST /api/auth/login
 */
export const login = asyncHandler(async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return next(new ApiError(400, "Email and password are required"));
    }

    // Get device info from request
    const deviceInfo = req.body.deviceInfo || "Unknown Device";
    const ipAddress = req.ip || req.connection.remoteAddress;
    const userAgent = req.get("user-agent") || "Unknown";

    const result = await authService.login({
      email,
      password,
      deviceInfo,
      ipAddress,
      userAgent,
    });

    // Set secure http-only cookie for refresh token
    res.cookie("refreshToken", result.data.tokens.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "strict",
      maxAge: 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    res.status(200).json(result);
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Refresh access token
 * POST /api/auth/refresh-token
 */
export const refreshToken = asyncHandler(async (req, res, next) => {
  try {
    const { userId } = req.user;
    const refreshToken = req.cookies.refreshToken || req.body.refreshToken;

    if (!refreshToken) {
      return next(new ApiError(401, "Refresh token required"));
    }

    const result = await authService.refreshAccessToken(refreshToken, userId);

    res.status(200).json({
      success: true,
      data: { accessToken: result.accessToken },
      message: "Token refreshed successfully",
    });
  } catch (error) {
    next(new ApiError(401, error.message));
  }
});

/**
 * Resend OTP
 * POST /api/auth/resend-otp
 */
export const resendOTP = asyncHandler(async (req, res, next) => {
  try {
    const { userId, contact, type } = req.body;

    if (!userId || !contact) {
      return next(new ApiError(400, "User ID and contact are required"));
    }

    const result = await authService.resendOTP(
      userId,
      contact,
      type || "email",
    );

    res.status(200).json({
      success: true,
      data: result,
      message: "OTP resent successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Logout user
 * POST /api/auth/logout
 */
export const logout = asyncHandler(async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { sessionId, allDevices } = req.body;

    const result = await authService.logout(userId, sessionId, allDevices);

    // Clear refresh token cookie
    res.clearCookie("refreshToken");

    res.status(200).json({
      success: true,
      data: result,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Change password
 * POST /api/auth/change-password
 */
export const changePassword = asyncHandler(async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { currentPassword, newPassword, confirmPassword } = req.body;

    if (!currentPassword || !newPassword || !confirmPassword) {
      return next(new ApiError(400, "All password fields are required"));
    }

    if (newPassword !== confirmPassword) {
      return next(new ApiError(400, "New passwords do not match"));
    }

    const result = await authService.changePassword(
      userId,
      currentPassword,
      newPassword,
    );

    res.clearCookie("refreshToken");

    res.status(200).json({
      success: true,
      data: result,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Request password reset
 * POST /api/auth/request-password-reset
 */
export const requestPasswordReset = asyncHandler(async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!email) {
      return next(new ApiError(400, "Email is required"));
    }

    const result = await authService.requestPasswordReset(email);

    res.status(200).json({
      success: true,
      data: result,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Reset password with OTP
 * POST /api/auth/reset-password
 */
export const resetPassword = asyncHandler(async (req, res, next) => {
  try {
    const { userId, otp, newPassword, confirmPassword } = req.body;

    if (!userId || !otp || !newPassword || !confirmPassword) {
      return next(
        new ApiError(
          400,
          "User ID, OTP, and password confirmation are required",
        ),
      );
    }

    if (newPassword !== confirmPassword) {
      return next(new ApiError(400, "Passwords do not match"));
    }

    const result = await authService.resetPassword(userId, otp, newPassword);

    res.clearCookie("refreshToken");

    res.status(200).json({
      success: true,
      data: result,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Send 2FA code
 * POST /api/auth/send-2fa
 */
export const send2FA = asyncHandler(async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { method } = req.body;

    const result = await authService.send2FACode(userId, method || "email");

    res.status(200).json({
      success: true,
      data: result,
      message: "2FA code sent successfully",
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Verify 2FA code
 * POST /api/auth/verify-2fa
 */
export const verify2FA = asyncHandler(async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { code, method } = req.body;

    if (!code) {
      return next(new ApiError(400, "2FA code is required"));
    }

    const result = await authService.verify2FA(userId, code, method || "email");

    res.status(200).json({
      success: true,
      data: result,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Get user sessions
 * GET /api/auth/sessions
 */
export const getSessions = asyncHandler(async (req, res, next) => {
  try {
    const { userId } = req.user;

    const sessions = await authService.getUserSessions(userId);

    res.status(200).json({
      success: true,
      data: sessions,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});

/**
 * Terminate session
 * DELETE /api/auth/sessions/:sessionId
 */
export const terminateSession = asyncHandler(async (req, res, next) => {
  try {
    const { userId } = req.user;
    const { sessionId } = req.params;

    if (!sessionId) {
      return next(new ApiError(400, "Session ID is required"));
    }

    const result = await authService.terminateSession(userId, sessionId);

    res.status(200).json({
      success: true,
      data: result,
      message: result.message,
    });
  } catch (error) {
    next(new ApiError(400, error.message));
  }
});
