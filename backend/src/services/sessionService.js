import db from "../config/database.js";
import crypto from "crypto";

/**
 * Session Management Service
 * Handles user sessions, device tracking, and session security
 */
export class SessionService {
  /**
   * Create a new session
   * @param {number} userId - User ID
   * @param {string} deviceInfo - Device information
   * @param {string} ipAddress - Client IP address
   * @param {string} userAgent - User agent string
   * @returns {Promise<Object>} Session data
   */
  async createSession(userId, deviceInfo, ipAddress, userAgent) {
    try {
      const sessionId = crypto.randomBytes(32).toString("hex");
      const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // 7 days

      // Invalidate old sessions if more than 3 active sessions
      const activeSessions = await db.query(
        "SELECT id FROM user_sessions WHERE user_id = $1 AND expires_at > NOW() ORDER BY created_at DESC",
        [userId],
      );

      if (activeSessions.length >= 3) {
        const sessionsToDelete = activeSessions.slice(3);
        for (const session of sessionsToDelete) {
          await this.invalidateSession(session.id);
        }
      }

      const session = await db.one(
        `INSERT INTO user_sessions (user_id, session_id, device_info, ip_address, user_agent, expires_at)
         VALUES ($1, $2, $3, $4, $5, $6)
         RETURNING id, session_id, user_id, device_info, created_at, expires_at`,
        [userId, sessionId, deviceInfo, ipAddress, userAgent, expiresAt],
      );

      return session;
    } catch (error) {
      throw new Error(`Session creation failed: ${error.message}`);
    }
  }

  /**
   * Validate session
   * @param {string} sessionId - Session ID
   * @param {number} userId - User ID
   * @returns {Promise<Object>} Session data if valid
   */
  async validateSession(sessionId, userId) {
    try {
      const session = await db.oneOrNone(
        `SELECT * FROM user_sessions 
         WHERE session_id = $1 AND user_id = $2 AND expires_at > NOW() AND is_active = true`,
        [sessionId, userId],
      );

      if (!session) {
        throw new Error("Session not found or expired");
      }

      // Update last accessed time
      await db.query(
        "UPDATE user_sessions SET last_accessed_at = NOW() WHERE id = $1",
        [session.id],
      );

      return session;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Invalidate session
   * @param {string|number} sessionId - Session ID or user ID
   * @param {boolean} allSessions - If true, invalidate all user sessions
   */
  async invalidateSession(sessionId, allSessions = false) {
    try {
      if (allSessions) {
        // sessionId is actually userId in this case
        await db.query(
          "UPDATE user_sessions SET is_active = false WHERE user_id = $1",
          [sessionId],
        );
      } else {
        await db.query(
          "UPDATE user_sessions SET is_active = false WHERE id = $1",
          [sessionId],
        );
      }
    } catch (error) {
      throw new Error(`Session invalidation failed: ${error.message}`);
    }
  }

  /**
   * Get user active sessions
   * @param {number} userId - User ID
   * @returns {Promise<Array>} Active sessions
   */
  async getUserSessions(userId) {
    try {
      const sessions = await db.query(
        `SELECT id, device_info, ip_address, created_at, last_accessed_at
         FROM user_sessions 
         WHERE user_id = $1 AND is_active = true AND expires_at > NOW()
         ORDER BY last_accessed_at DESC`,
        [userId],
      );

      return sessions;
    } catch (error) {
      throw error;
    }
  }

  /**
   * Track failed login attempt
   * @param {string} email - User email
   * @param {string} ipAddress - Client IP
   */
  async trackFailedLogin(email, ipAddress) {
    try {
      const key = `failed_login:${email}:${ipAddress}`;
      const attempts = await db.oneOrNone(
        "SELECT attempts, last_attempt FROM login_attempts WHERE email = $1 AND ip_address = $2",
        [email, ipAddress],
      );

      if (!attempts) {
        await db.query(
          "INSERT INTO login_attempts (email, ip_address, attempts, last_attempt) VALUES ($1, $2, 1, NOW())",
          [email, ipAddress],
        );
      } else {
        await db.query(
          "UPDATE login_attempts SET attempts = attempts + 1, last_attempt = NOW() WHERE email = $1 AND ip_address = $2",
          [email, ipAddress],
        );
      }
    } catch (error) {
      throw error;
    }
  }

  /**
   * Clear failed login attempts
   * @param {string} email - User email
   */
  async clearFailedLogin(email) {
    try {
      await db.query("DELETE FROM login_attempts WHERE email = $1", [email]);
    } catch (error) {
      throw error;
    }
  }

  /**
   * Check if account is locked
   * @param {string} email - User email
   * @param {string} ipAddress - Client IP
   * @returns {Promise<boolean>}
   */
  async isAccountLocked(email, ipAddress) {
    try {
      const attempts = await db.oneOrNone(
        "SELECT attempts, last_attempt FROM login_attempts WHERE email = $1 AND ip_address = $2",
        [email, ipAddress],
      );

      if (!attempts) return false;

      // Lock account for 30 minutes after 5 failed attempts
      const lockoutDuration = 30 * 60 * 1000;
      const timeSinceLastAttempt =
        Date.now() - new Date(attempts.last_attempt).getTime();

      if (attempts.attempts >= 5 && timeSinceLastAttempt < lockoutDuration) {
        return true;
      }

      // Reset if lock period expired
      if (attempts.attempts >= 5 && timeSinceLastAttempt >= lockoutDuration) {
        await this.clearFailedLogin(email);
        return false;
      }

      return false;
    } catch (error) {
      throw error;
    }
  }
}

export default new SessionService();
