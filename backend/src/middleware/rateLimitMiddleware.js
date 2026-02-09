import db from "../config/database.js";
import { ApiError } from "../utils/errors.js";

/**
 * Rate Limiting Middleware
 * Prevents brute force attacks and API abuse
 */

const rateLimitStore = new Map(); // In-memory store (use Redis for production)

/**
 * Create rate limit key from request
 */
function createKey(identifier, endpoint) {
  return `${identifier}:${endpoint}`;
}

/**
 * General rate limiter
 * @param {number} maxRequests - Maximum requests allowed
 * @param {number} windowMs - Time window in milliseconds
 */
export function rateLimit(maxRequests = 100, windowMs = 15 * 60 * 1000) {
  return (req, res, next) => {
    const identifier = req.ip || req.connection.remoteAddress;
    const key = createKey(identifier, req.path);

    const now = Date.now();
    const requests = rateLimitStore.get(key) || [];

    // Remove old requests outside the window
    const validRequests = requests.filter((timestamp) => now - timestamp < windowMs);

    if (validRequests.length >= maxRequests) {
      const nextAvailable = new Date(validRequests[0] + windowMs);
      return next(
        new ApiError(
          429,
          `Too many requests. Please try again after ${nextAvailable.toLocaleTimeString()}`
        )
      );
    }

    validRequests.push(now);
    rateLimitStore.set(key, validRequests);

    res.setHeader("X-RateLimit-Limit", maxRequests);
    res.setHeader("X-RateLimit-Remaining", maxRequests - validRequests.length);
    res.setHeader("X-RateLimit-Reset", new Date(validRequests[0] + windowMs));

    next();
  };
}

/**
 * Strict rate limiter for login attempts
 * 5 attempts per 30 minutes per email + IP
 */
export function loginRateLimit(req, res, next) {
  const email = req.body.email || "unknown";
  const ipAddress = req.ip || req.connection.remoteAddress;
  const key = createKey(`${email}:${ipAddress}`, "login");

  const now = Date.now();
  const windowMs = 30 * 60 * 1000; // 30 minutes
  const maxAttempts = 5;

  const requests = rateLimitStore.get(key) || [];
  const validRequests = requests.filter((timestamp) => now - timestamp < windowMs);

  if (validRequests.length >= maxAttempts) {
    const lockoutTime = Math.ceil(
      (validRequests[0] + windowMs - now) / 60000
    );
    return next(
      new ApiError(
        429,
        `Too many login attempts. Try again in ${lockoutTime} minutes.`
      )
    );
  }

  validRequests.push(now);
  rateLimitStore.set(key, validRequests);

  res.setHeader("X-Login-Attempts-Remaining", maxAttempts - validRequests.length);

  next();
}

/**
 * Strict rate limiter for OTP requests
 * 3 attempts per hour per user
 */
export function otpRateLimit(req, res, next) {
  const userId = req.body.userId || (req.user && req.user.id) || "unknown";
  const key = createKey(`${userId}`, "otp");

  const now = Date.now();
  const windowMs = 60 * 60 * 1000; // 1 hour
  const maxAttempts = 3;

  const requests = rateLimitStore.get(key) || [];
  const validRequests = requests.filter((timestamp) => now - timestamp < windowMs);

  if (validRequests.length >= maxAttempts) {
    const retryTime = Math.ceil(
      (validRequests[0] + windowMs - now) / 60000
    );
    return next(
      new ApiError(
        429,
        `Too many OTP requests. Try again in ${retryTime} minutes.`
      )
    );
  }

  validRequests.push(now);
  rateLimitStore.set(key, validRequests);

  res.setHeader("X-OTP-Attempts-Remaining", maxAttempts - validRequests.length);

  next();
}

/**
 * Password reset rate limiter
 * 3 attempts per hour per email
 */
export function passwordResetRateLimit(req, res, next) {
  const email = req.body.email || "unknown";
  const key = createKey(`${email}`, "password-reset");

  const now = Date.now();
  const windowMs = 60 * 60 * 1000; // 1 hour
  const maxAttempts = 3;

  const requests = rateLimitStore.get(key) || [];
  const validRequests = requests.filter((timestamp) => now - timestamp < windowMs);

  if (validRequests.length >= maxAttempts) {
    const retryTime = Math.ceil(
      (validRequests[0] + windowMs - now) / 60000
    );
    return next(
      new ApiError(
        429,
        `Too many password reset requests. Try again in ${retryTime} minutes.`
      )
    );
  }

  validRequests.push(now);
  rateLimitStore.set(key, validRequests);

  next();
}

/**
 * API endpoint rate limiter
 * Different limits for different user types
 */
export function apiRateLimit(req, res, next) {
  const identifier = req.user ? req.user.id : (req.ip || req.connection.remoteAddress);
  const key = createKey(`${identifier}`, "api");

  const now = Date.now();
  const windowMs = 60 * 1000; // 1 minute

  // Limits per minute per user type
  let maxRequests = 100; // Default for free users
  if (req.user) {
    if (req.user.userType === "admin") maxRequests = 1000;
    else if (req.user.userType === "charger_owner") maxRequests = 500;
    else if (req.user.userType === "driver") maxRequests = 200;
  }

  const requests = rateLimitStore.get(key) || [];
  const validRequests = requests.filter((timestamp) => now - timestamp < windowMs);

  if (validRequests.length >= maxRequests) {
    return next(
      new ApiError(429, "API rate limit exceeded. Please try again later.")
    );
  }

  validRequests.push(now);
  rateLimitStore.set(key, validRequests);

  res.setHeader("X-RateLimit-Limit", maxRequests);
  res.setHeader("X-RateLimit-Remaining", maxRequests - validRequests.length);

  next();
}

/**
 * Clean up expired rate limit entries (call periodically)
 */
export function cleanupRateLimits() {
  const now = Date.now();
  const maxWindowMs = 60 * 60 * 1000; // 1 hour

  for (const [key, timestamps] of rateLimitStore.entries()) {
    const validTimestamps = timestamps.filter(
      (timestamp) => now - timestamp < maxWindowMs
    );

    if (validTimestamps.length === 0) {
      rateLimitStore.delete(key);
    } else {
      rateLimitStore.set(key, validTimestamps);
    }
  }
}

// Cleanup every 30 minutes
setInterval(cleanupRateLimits, 30 * 60 * 1000);

export default {
  rateLimit,
  loginRateLimit,
  otpRateLimit,
  passwordResetRateLimit,
  apiRateLimit,
  cleanupRateLimits,
};
