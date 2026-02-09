import db from "../../config/database.js";
import jwt from "jsonwebtoken";
import { jwtConfig } from "../../config/jwt.js";
import {
  generateOTP,
  hashPassword,
  comparePassword,
  generateSecureToken,
} from "../../utils/helpers.js";
import { sendOTP, sendSecurityAlert } from "../../utils/emailService.js";
import sessionService from "../../services/sessionService.js";
import otpService from "../../services/otpService.js";

/**
 * Enhanced Authentication Service
 * Provides secure user registration, login, and token management
 */
export class AuthService {
  /**
   * Validate password strength
   * Password must be at least 8 characters with numbers, uppercase, lowercase, and special chars
   */
  validatePasswordStrength(password) {
    const requirements = {
      minLength: password.length >= 8,
      hasUpperCase: /[A-Z]/.test(password),
      hasLowerCase: /[a-z]/.test(password),
      hasNumbers: /[0-9]/.test(password),
      hasSpecialChar: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password),
    };

    const isValid = Object.values(requirements).every(Boolean);
    const failedRequirements = Object.keys(requirements).filter(
      (key) => !requirements[key],
    );

    return {
      isValid,
      requirements,
      failedRequirements,
    };
  }

  /**
   * Register new user
   * @param {Object} userData - User registration data
   * @returns {Promise<Object>} Registration result
   */
  async register(userData) {
    try {
      const { email, phone, password, firstName, lastName, userType } =
        userData;

      // Check if user exists
      const existingUser = await db.oneOrNone(
        "SELECT id, email, phone FROM users WHERE email = $1 OR phone = $2",
        [email, phone],
      );

      if (existingUser) {
        const conflict = existingUser.email === email ? "email" : "phone";
        throw new Error(`User already exists with this ${conflict}`);
      }

      // Validate password strength
      const passwordValidation = this.validatePasswordStrength(password);
      if (!passwordValidation.isValid) {
        throw new Error(
          `Weak password. Requirements: ${passwordValidation.failedRequirements.join(", ")}`,
        );
      }

      // Hash password
      const hashedPassword = await hashPassword(password);

      // Create user
      const user = await db.one(
        `INSERT INTO users (email, phone, password, first_name, last_name, user_type, 
         is_verified, account_status, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, false, 'pending_verification', NOW())
         RETURNING id, email, phone, first_name, last_name, user_type, created_at`,
        [email, phone, hashedPassword, firstName, lastName, userType],
      );

      // Generate and send email OTP
      const emailOTP = await otpService.generateAndSendOTP(user.id, email);

      return {
        userId: user.id,
        email: user.email,
        phone: user.phone,
        userType: user.user_type,
        message: "Registration successful. OTP sent to your email.",
        otpId: emailOTP.otpId,
        expiresIn: emailOTP.expiresIn,
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Verify email OTP and mark user as verified
   * @param {number} userId - User ID
   * @param {string} otp - OTP code
   * @returns {Promise<Object>} User and tokens
   */
  async verifyEmailOTP(userId, otp) {
    try {
      // Verify OTP
      await otpService.verifyOTP(userId, otp, "email");

      // Update user verification status
      const user = await db.one(
        `UPDATE users SET is_verified = true, verified_at = NOW(), account_status = 'active'
         WHERE id = $1
         RETURNING id, email, phone, first_name, last_name, user_type, average_rating`,
        [userId],
      );

      return {
        success: true,
        message: "Email verified successfully",
        user,
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Verify phone OTP
   * @param {number} userId - User ID
   * @param {string} otp - OTP code
   * @returns {Promise<Object>}
   */
  async verifyPhoneOTP(userId, otp) {
    try {
      // Verify OTP
      await otpService.verifyOTP(userId, otp, "phone");

      // Update user
      const user = await db.one(
        `UPDATE users SET phone_verified = true, phone_verified_at = NOW()
         WHERE id = $1
         RETURNING id, email, phone, first_name, last_name, user_type`,
        [userId],
      );

      return {
        success: true,
        message: "Phone verified successfully",
        user,
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Enhanced login with session creation
   * @param {Object} loginData - Login credentials and device info
   * @returns {Promise<Object>} User, tokens, and session
   */
  async login(loginData) {
    try {
      const { email, password, deviceInfo, ipAddress, userAgent } = loginData;

      // Check account lockout
      const isLocked = await sessionService.isAccountLocked(email, ipAddress);
      if (isLocked) {
        throw new Error(
          "Account temporarily locked due to multiple failed login attempts. Try again later.",
        );
      }

      // Find user
      const user = await db.oneOrNone("SELECT * FROM users WHERE email = $1", [
        email,
      ]);

      if (!user) {
        await sessionService.trackFailedLogin(email, ipAddress);
        throw new Error("Invalid email or password");
      }

      // Check account status
      if (user.account_status === "suspended") {
        throw new Error(
          "Account suspended. Contact support for more information.",
        );
      }

      if (user.account_status === "inactive") {
        throw new Error("Account inactive");
      }

      // Verify password
      const isPasswordValid = await comparePassword(password, user.password);
      if (!isPasswordValid) {
        await sessionService.trackFailedLogin(email, ipAddress);
        throw new Error("Invalid email or password");
      }

      // Check email verification
      if (!user.is_verified) {
        throw new Error("Please verify your email first");
      }

      // Clear failed login attempts
      await sessionService.clearFailedLogin(email);

      // Create session
      const session = await sessionService.createSession(
        user.id,
        deviceInfo,
        ipAddress,
        userAgent,
      );

      // Generate tokens
      const accessToken = jwt.sign(
        {
          id: user.id,
          email: user.email,
          userType: user.user_type,
          sessionId: session.session_id,
        },
        jwtConfig.secret,
        { expiresIn: jwtConfig.expiresIn },
      );

      const refreshToken = jwt.sign(
        {
          id: user.id,
          sessionId: session.session_id,
        },
        jwtConfig.refreshSecret,
        { expiresIn: jwtConfig.refreshExpiresIn },
      );

      // Update last login
      await db.query(
        `UPDATE users SET last_login_at = NOW(), last_login_ip = $1 
         WHERE id = $2`,
        [ipAddress, user.id],
      );

      return {
        success: true,
        message: "Login successful",
        data: {
          user: {
            id: user.id,
            email: user.email,
            phone: user.phone,
            firstName: user.first_name,
            lastName: user.last_name,
            userType: user.user_type,
            profileImage: user.profile_image,
            averageRating: user.average_rating,
          },
          tokens: {
            accessToken,
            refreshToken,
            expiresIn: jwtConfig.expiresIn,
          },
          session: {
            sessionId: session.session_id,
            deviceInfo: session.device_info,
          },
        },
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Refresh access token
   * @param {string} refreshToken - Refresh token
   * @param {number} userId - User ID
   * @returns {Promise<Object>} New access token
   */
  async refreshAccessToken(refreshToken, userId) {
    try {
      // Verify refresh token
      let decoded;
      try {
        decoded = jwt.verify(refreshToken, jwtConfig.refreshSecret);
      } catch (error) {
        throw new Error("Invalid or expired refresh token");
      }

      if (decoded.id !== userId) {
        throw new Error("Token mismatch");
      }

      // Validate session
      await sessionService.validateSession(decoded.sessionId, userId);

      // Get user
      const user = await db.one(
        "SELECT id, email, user_type FROM users WHERE id = $1",
        [userId],
      );

      // Generate new access token
      const accessToken = jwt.sign(
        {
          id: user.id,
          email: user.email,
          userType: user.user_type,
          sessionId: decoded.sessionId,
        },
        jwtConfig.secret,
        { expiresIn: jwtConfig.expiresIn },
      );

      return {
        success: true,
        accessToken,
        expiresIn: jwtConfig.expiresIn,
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Logout user and invalidate session
   * @param {number} userId - User ID
   * @param {string} sessionId - Session ID
   * @param {boolean} allDevices - Logout from all devices
   * @returns {Promise<Object>}
   */
  async logout(userId, sessionId, allDevices = false) {
    try {
      if (allDevices) {
        await sessionService.invalidateSession(userId, true);
      } else {
        await sessionService.invalidateSession(sessionId);
      }

      return {
        success: true,
        message: allDevices
          ? "Logged out from all devices"
          : "Logged out successfully",
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Change password
   * @param {number} userId - User ID
   * @param {string} currentPassword - Current password
   * @param {string} newPassword - New password
   * @returns {Promise<Object>}
   */
  async changePassword(userId, currentPassword, newPassword) {
    try {
      // Get user
      const user = await db.one("SELECT password FROM users WHERE id = $1", [
        userId,
      ]);

      // Verify current password
      const isValid = await comparePassword(currentPassword, user.password);
      if (!isValid) {
        throw new Error("Current password is incorrect");
      }

      // Validate new password strength
      const passwordValidation = this.validatePasswordStrength(newPassword);
      if (!passwordValidation.isValid) {
        throw new Error(
          `Weak password. Requirements: ${passwordValidation.failedRequirements.join(", ")}`,
        );
      }

      // Hash new password
      const hashedPassword = await hashPassword(newPassword);

      // Update password
      await db.query("UPDATE users SET password = $1 WHERE id = $2", [
        hashedPassword,
        userId,
      ]);

      // Logout from all sessions
      await sessionService.invalidateSession(userId, true);

      return {
        success: true,
        message: "Password changed successfully. Please login again.",
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Request password reset
   * @param {string} email - User email
   * @returns {Promise<Object>}
   */
  async requestPasswordReset(email) {
    try {
      const user = await db.oneOrNone("SELECT id FROM users WHERE email = $1", [
        email,
      ]);

      if (!user) {
        // Don't reveal if email exists (security)
        return {
          success: true,
          message: "If email exists, reset link sent. Please check your inbox.",
        };
      }

      // Generate reset OTP
      const { otpId, expiresIn } = await otpService.generatePasswordResetOTP(
        user.id,
        email,
      );

      return {
        success: true,
        message: "Reset OTP sent to your email",
        otpId,
        expiresIn,
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Reset password with OTP
   * @param {number} userId - User ID
   * @param {string} otp - Reset OTP
   * @param {string} newPassword - New password
   * @returns {Promise<Object>}
   */
  async resetPassword(userId, otp, newPassword) {
    try {
      // Verify OTP
      await otpService.verifyOTP(userId, otp, "password_reset");

      // Validate password strength
      const passwordValidation = this.validatePasswordStrength(newPassword);
      if (!passwordValidation.isValid) {
        throw new Error(
          `Weak password. Requirements: ${passwordValidation.failedRequirements.join(", ")}`,
        );
      }

      // Hash and update password
      const hashedPassword = await hashPassword(newPassword);
      await db.query("UPDATE users SET password = $1 WHERE id = $2", [
        hashedPassword,
        userId,
      ]);

      // Invalidate all sessions
      await sessionService.invalidateSession(userId, true);

      return {
        success: true,
        message: "Password reset successfully. Please login with new password.",
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Send two-factor auth code
   * @param {number} userId - User ID
   * @param {string} method - '2fa_method' from user settings
   * @returns {Promise<Object>}
   */
  async send2FACode(userId, method = "email") {
    try {
      const user = await db.one(
        "SELECT id, email, phone FROM users WHERE id = $1",
        [userId],
      );

      if (method === "email") {
        return await otpService.generateAndSendOTP(user.id, user.email);
      } else if (method === "phone") {
        return await otpService.generateAndSendPhoneOTP(user.id, user.phone);
      }

      throw new Error("Invalid 2FA method");
    } catch (error) {
      throw error;
    }
  }

  /**
   * Verify two-factor auth code
   * @param {number} userId - User ID
   * @param {string} code - 2FA code
   * @param {string} method - 2FA method
   * @returns {Promise<Object>}
   */
  async verify2FA(userId, code, method = "email") {
    try {
      const type = method === "email" ? "email" : "phone";
      await otpService.verifyOTP(userId, code, type);

      return {
        success: true,
        message: "2FA verified successfully",
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Resend OTP
   * @param {number} userId - User ID
   * @param {string} contact - Email or phone
   * @param {string} type - OTP type
   * @returns {Promise<Object>}
   */
  async resendOTP(userId, contact, type = "email") {
    try {
      return await otpService.resendOTP(userId, contact, type);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Get user sessions
   * @param {number} userId - User ID
   * @returns {Promise<Array>}
   */
  async getUserSessions(userId) {
    try {
      return await sessionService.getUserSessions(userId);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Terminate specific session
   * @param {number} userId - User ID
   * @param {string} sessionId - Session ID
   * @returns {Promise<Object>}
   */
  async terminateSession(userId, sessionId) {
    try {
      const session = await db.oneOrNone(
        "SELECT id FROM user_sessions WHERE id = $1 AND user_id = $2",
        [sessionId, userId],
      );

      if (!session) {
        throw new Error("Session not found");
      }

      await sessionService.invalidateSession(sessionId);

      return {
        success: true,
        message: "Session terminated successfully",
      };
    } catch (error) {
      throw error;
    }
  }
}

export default new AuthService();
