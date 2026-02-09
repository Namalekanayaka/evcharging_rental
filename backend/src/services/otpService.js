import db from "../config/database.js";
import { sendOTP, sendOTPtoPhone } from "../utils/emailService.js";
import crypto from "crypto";

/**
 * OTP Service
 * Handles OTP generation, validation, and delivery via email and SMS
 */
export class OTPService {
  /**
   * Generate and send OTP via email
   * @param {number} userId - User ID
   * @param {string} email - Email address
   * @param {number} length - OTP length (default 6)
   * @returns {Promise<Object>}
   */
  async generateAndSendOTP(userId, email, length = 6) {
    try {
      // Check OTP rate limit (max 3 OTP requests per hour)
      const recentOTPs = await db.query(
        `SELECT COUNT(*) as count FROM otp_codes 
         WHERE user_id = $1 AND created_at > NOW() - INTERVAL '1 hour'`,
        [userId]
      );

      if (recentOTPs[0].count >= 3) {
        throw new Error("Too many OTP requests. Please try again after 1 hour.");
      }

      // Generate OTP
      const otp = Math.random()
        .toString()
        .slice(2, 2 + length)
        .padStart(length, "0");

      const otpExpiry = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
      const createdAt = new Date();

      // Store OTP
      const otpRecord = await db.one(
        `INSERT INTO otp_codes (user_id, code, type, expires_at, created_at)
         VALUES ($1, $2, 'email', $3, $4)
         RETURNING id, user_id, code, expires_at`,
        [userId, otp, otpExpiry, createdAt]
      );

      // Send OTP via email
      await sendOTP(email, otp);

      return {
        success: true,
        message: "OTP sent to your email",
        otpId: otpRecord.id,
        expiresIn: 600000, // 10 minutes in milliseconds
      };
    } catch (error) {
      throw new Error(`OTP generation failed: ${error.message}`);
    }
  }

  /**
   * Generate and send OTP via SMS
   * @param {number} userId - User ID
   * @param {string} phone - Phone number
   * @param {number} length - OTP length (default 6)
   * @returns {Promise<Object>}
   */
  async generateAndSendPhoneOTP(userId, phone, length = 6) {
    try {
      // Check OTP rate limit
      const recentOTPs = await db.query(
        `SELECT COUNT(*) as count FROM otp_codes 
         WHERE user_id = $1 AND created_at > NOW() - INTERVAL '1 hour'`,
        [userId]
      );

      if (recentOTPs[0].count >= 3) {
        throw new Error("Too many OTP requests. Please try again after 1 hour.");
      }

      // Generate OTP
      const otp = Math.random()
        .toString()
        .slice(2, 2 + length)
        .padStart(length, "0");

      const otpExpiry = new Date(Date.now() + 10 * 60 * 1000);
      const createdAt = new Date();

      // Store OTP
      const otpRecord = await db.one(
        `INSERT INTO otp_codes (user_id, code, type, expires_at, created_at)
         VALUES ($1, $2, 'phone', $3, $4)
         RETURNING id, user_id, code, expires_at`,
        [userId, otp, otpExpiry, createdAt]
      );

      // Send OTP via SMS (implement based on SMS provider)
      // await sendOTPtoPhone(phone, otp);

      return {
        success: true,
        message: "OTP sent to your phone",
        otpId: otpRecord.id,
        expiresIn: 600000, // 10 minutes
      };
    } catch (error) {
      throw new Error(`Phone OTP generation failed: ${error.message}`);
    }
  }

  /**
   * Verify OTP
   * @param {number} userId - User ID
   * @param {string} otp - OTP code
   * @param {string} type - OTP type ('email' or 'phone')
   * @returns {Promise<Object>} Verified result
   */
  async verifyOTP(userId, otp, type = "email") {
    try {
      const otpRecord = await db.oneOrNone(
        `SELECT * FROM otp_codes 
         WHERE user_id = $1 AND code = $2 AND type = $3 
         AND expires_at > NOW() AND is_used = false`,
        [userId, otp, type]
      );

      if (!otpRecord) {
        throw new Error("Invalid or expired OTP");
      }

      // Mark as used
      await db.query("UPDATE otp_codes SET is_used = true WHERE id = $1", [
        otpRecord.id,
      ]);

      return {
        success: true,
        message: "OTP verified successfully",
        otpId: otpRecord.id,
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
      // Invalidate previous unused OTPs
      await db.query(
        `UPDATE otp_codes SET is_used = true 
         WHERE user_id = $1 AND type = $2 AND is_used = false`,
        [userId, type]
      );

      if (type === "email") {
        return await this.generateAndSendOTP(userId, contact);
      } else if (type === "phone") {
        return await this.generateAndSendPhoneOTP(userId, contact);
      }

      throw new Error("Invalid OTP type");
    } catch (error) {
      throw error;
    }
  }

  /**
   * Generate OTP for password reset
   * @param {number} userId - User ID
   * @param {string} email - User email
   * @returns {Promise<Object>}
   */
  async generatePasswordResetOTP(userId, email) {
    try {
      // Generate OTP
      const otp = Math.random()
        .toString()
        .slice(2, 8)
        .padStart(6, "0");

      const otpExpiry = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes

      const otpRecord = await db.one(
        `INSERT INTO otp_codes (user_id, code, type, expires_at)
         VALUES ($1, $2, 'password_reset', $3)
         RETURNING id, expires_at`,
        [userId, otp, otpExpiry]
      );

      // Send OTP
      await sendOTP(email, otp, "Password Reset");

      return {
        success: true,
        message: "Reset OTP sent to your email",
        otpId: otpRecord.id,
        expiresIn: 900000, // 15 minutes
      };
    } catch (error) {
      throw error;
    }
  }

  /**
   * Clean up expired OTPs
   * @returns {Promise<Object>}
   */
  async cleanupExpiredOTPs() {
    try {
      const result = await db.query(
        "DELETE FROM otp_codes WHERE expires_at < NOW()"
      );

      return {
        success: true,
        deletedCount: result.rowCount,
      };
    } catch (error) {
      throw error;
    }
  }
}

export default new OTPService();
