import jwt from "jsonwebtoken";
import db from "../config/database.js";
import { jwtConfig } from "../config/jwt.js";
import { ApiError } from "../utils/errors.js";

/**
 * Enhanced Authentication Middleware
 * Verifies JWT token and validates session
 */
export const authMiddleware = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    if (!token) {
      throw new ApiError(401, "No token provided");
    }

    let decoded;
    try {
      decoded = jwt.verify(token, jwtConfig.secret);
    } catch (error) {
      if (error instanceof jwt.TokenExpiredError) {
        throw new ApiError(401, "Token expired");
      }
      if (error instanceof jwt.JsonWebTokenError) {
        throw new ApiError(401, "Invalid token");
      }
      throw error;
    }

    // Validate session if sessionId is present
    if (decoded.sessionId) {
      try {
        const session = await db.oneOrNone(
          `SELECT id FROM user_sessions 
           WHERE session_id = $1 AND user_id = $2 AND is_active = true AND expires_at > NOW()`,
          [decoded.sessionId, decoded.id],
        );

        if (!session) {
          throw new ApiError(401, "Session invalid or expired");
        }
      } catch (sessionError) {
        if (sessionError instanceof ApiError) throw sessionError;
        throw new ApiError(401, "Session validation failed");
      }
    }

    // Validate user still exists and is active
    const user = await db.oneOrNone(
      `SELECT id, account_status FROM users WHERE id = $1`,
      [decoded.id],
    );

    if (!user) {
      throw new ApiError(401, "User not found");
    }

    if (user.account_status === "suspended") {
      throw new ApiError(403, "Account suspended");
    }

    if (user.account_status === "inactive") {
      throw new ApiError(403, "Account inactive");
    }

    req.user = decoded;
    next();
  } catch (error) {
    if (error instanceof ApiError) {
      return next(error);
    }
    next(new ApiError(401, "Authentication failed"));
  }
};

/**
 * Optional Authentication Middleware
 * Auth is optional, doesn't fail if no token provided
 */
export const optionalAuth = async (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(" ")[1];

    if (token) {
      try {
        const decoded = jwt.verify(token, jwtConfig.secret);

        // Validate session if present
        if (decoded.sessionId) {
          const session = await db.oneOrNone(
            `SELECT id FROM user_sessions 
             WHERE session_id = $1 AND user_id = $2 AND is_active = true AND expires_at > NOW()`,
            [decoded.sessionId, decoded.id],
          );

          if (!session) {
            // Session invalid, but don't fail since auth is optional
            return next();
          }
        }

        req.user = decoded;
      } catch (error) {
        // Auth optional, ignore token errors
      }
    }
  } catch (error) {
    // Silent fail for optional auth
  }

  next();
};

/**
 * Require User ID from Token
 * Ensures that the authenticated user owns the resource they're accessing
 */
export const requireOwnResource = (req, res, next) => {
  const { userId } = req.params;
  const { id: authenticatedUserId } = req.user;

  if (parseInt(userId) !== parseInt(authenticatedUserId)) {
    return next(
      new ApiError(403, "You do not have permission to access this resource"),
    );
  }

  next();
};

/**
 * Two-Factor Authentication Middleware
 * Checks if user has 2FA enabled and verified
 */
export const require2FA = async (req, res, next) => {
  try {
    const { id: userId } = req.user;

    const user = await db.oneOrNone(
      `SELECT two_fa_enabled, two_fa_verified FROM users WHERE id = $1`,
      [userId],
    );

    if (!user) {
      return next(new ApiError(401, "User not found"));
    }

    if (user.two_fa_enabled && !user.two_fa_verified) {
      return next(new ApiError(403, "Two-factor authentication required"));
    }

    next();
  } catch (error) {
    next(new ApiError(500, "2FA verification failed"));
  }
};

/**
 * Email Verification Middleware
 * Ensures user has verified their email
 */
export const requireEmailVerification = async (req, res, next) => {
  try {
    const { id: userId } = req.user;

    const user = await db.oneOrNone(
      `SELECT is_verified FROM users WHERE id = $1`,
      [userId],
    );

    if (!user) {
      return next(new ApiError(401, "User not found"));
    }

    if (!user.is_verified) {
      return next(
        new ApiError(
          403,
          "Email verification required. Please check your inbox.",
        ),
      );
    }

    next();
  } catch (error) {
    next(new ApiError(500, "Email verification check failed"));
  }
};

/**
 * Phone Verification Middleware
 * Ensures user has verified their phone number
 */
export const requirePhoneVerification = async (req, res, next) => {
  try {
    const { id: userId } = req.user;

    const user = await db.oneOrNone(
      `SELECT phone_verified FROM users WHERE id = $1`,
      [userId],
    );

    if (!user) {
      return next(new ApiError(401, "User not found"));
    }

    if (!user.phone_verified) {
      return next(new ApiError(403, "Phone verification required"));
    }

    next();
  } catch (error) {
    next(new ApiError(500, "Phone verification check failed"));
  }
};

/**
 * Session Activity Update Middleware
 * Updates session activity on each request
 */
export const updateSessionActivity = async (req, res, next) => {
  try {
    if (req.user && req.user.sessionId) {
      await db.query(
        `UPDATE user_sessions SET last_accessed_at = NOW() 
         WHERE session_id = $1`,
        [req.user.sessionId],
      );
    }
  } catch (error) {
    // Non-critical, don't fail
  }

  next();
};

export default authMiddleware;
