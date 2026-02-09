# Secure Authentication & Authorization System

## Complete Implementation Guide

This document provides a comprehensive guide to the complete authentication and authorization system for the EV Charger Rental Platform.

---

## Backend Implementation

### 1. Core Services

#### Enhanced Auth Service (`authService.js`)
- **Password Strength Validation**: Enforces 8+ characters with uppercase, lowercase, numbers, and special characters
- **Email OTP Verification**: 10-minute expiration with rate limiting
- **Phone OTP Verification**: SMS-based OTP (ready for integration)
- **Session Management**: Track device, IP, and last access time
- **Token Refresh**: Secure refresh token rotation
- **2FA Support**: Both email and SMS-based 2FA
- **Password Reset**: Secure OTP-based password reset
- **Account Lockout Protection**: 5 failed attempts lock account for 30 minutes

#### Session Service (`sessionService.js`)
- **Multi-Device Support**: Max 3 concurrent sessions per user
- **Session Tracking**: Device info, IP address, last accessed time
- **Failed Login Tracking**: IP-based tracking for brute force protection
- **Active Session Management**: Logout from single device or all devices
- **Session Validation**: Verify session on each request

#### OTP Service (`otpService.js`)
- **Dual Channel Support**: Email and SMS OTP delivery
- **Rate Limiting**: Max 3 OTP requests per hour per user
- **Expiration Management**: 10 minutes for standard, 15 for password reset
- **Type Support**: Email, phone, password reset OTP types
- **Cleanup**: Automatic cleanup of expired OTPs

### 2. Enhanced Middleware

#### Auth Middleware (`authMiddleware.js`)
```javascript
// Features:
- JWT token verification
- Session validation
- User status checks (suspended/inactive)
- Optional auth mode
- Resource ownership verification
- Email/phone verification checks
- 2FA requirement enforcement
- Session activity updates
```

#### Rate Limiting Middleware (`rateLimitMiddleware.js`)
```javascript
// Rate Limits:
- Login: 5 attempts per 30 minutes per IP
- OTP: 3 requests per hour per user
- Password Reset: 3 attempts per hour per email
- General API: 100-1000 req/min based on user role
  - Drivers: 200 req/min
  - Owners: 500 req/min
  - Admins: 1000 req/min
```

### 3. Authentication Routes

**Public Routes:**
- `POST /api/auth/register` - New user registration
- `POST /api/auth/verify-email-otp` - Verify email OTP
- `POST /api/auth/verify-phone-otp` - Verify phone OTP
- `POST /api/auth/login` - Secure login with device tracking
- `POST /api/auth/resend-otp` - Resend OTP via email/SMS
- `POST /api/auth/request-password-reset` - Request password reset
- `POST /api/auth/reset-password` - Reset with OTP

**Protected Routes:**
- `POST /api/auth/refresh-token` - Get new access token
- `POST /api/auth/logout` - Logout (single or all devices)
- `POST /api/auth/change-password` - Change password
- `POST /api/auth/send-2fa` - Send 2FA code
- `POST /api/auth/verify-2fa` - Verify 2FA
- `GET /api/auth/sessions` - List active sessions
- `DELETE /api/auth/sessions/:sessionId` - Terminate session

---

## Flutter Integration

### 1. Secure Token Storage

#### SecureTokenStorage Service
```dart
// Stores in secure vault:
- Access token (JWT)
- Refresh token
- Session ID
- User ID
- Device info

// Features:
- Encrypted storage
- Atomic operations
- Token expiration checks
- Batch operations
```

**Usage:**
```dart
final storage = getIt<SecureTokenStorage>();
await storage.saveAuthData(
  accessToken: token,
  refreshToken: refreshToken,
  sessionId: sessionId,
  userId: userId,
  deviceInfo: deviceInfo,
);
```

### 2. Auth Repository

#### Implementation
```dart
class AuthRepository {
  // Registration flow
  Future<Map> register({...})
  
  // OTP verification
  Future<UserEntity> verifyEmailOTP({...})
  Future<UserEntity> verifyPhoneOTP({...})
  
  // Login with device info
  Future<Map> login({...})
  
  // Token management
  Future<String> refreshAccessToken()
  Future<void> logout({allDevices})
  
  // Password management
  Future<void> changePassword({...})
  Future<void> requestPasswordReset({...})
  Future<void> resetPassword({...})
  
  // 2FA
  Future<void> send2FA({method})
  Future<void> verify2FA({code, method})
  
  // Session management
  Future<List> getUserSessions()
  Future<void> terminateSession({sessionId})
}
```

### 3. Enhanced Auth BLoC

#### Events
- `CheckAuthStatusEvent` - Check if already logged in
- `RegisterEvent` - User registration
- `VerifyEmailOTPEvent` - Verify email OTP
- `VerifyPhoneOTPEvent` - Verify phone OTP  
- `LoginEvent` - Secure login
- `ResendOTPEvent` - Resend OTP
- `RefreshTokenEvent` - Refresh access token
- `LogoutEvent` - Logout (single or all)
- `ChangePasswordEvent` - Change password
- `RequestPasswordResetEvent` - Request reset
- `ResetPasswordEvent` - Reset password
- `Send2FAEvent` - Send 2FA code
- `Verify2FAEvent` - Verify 2FA code
- `GetSessionsEvent` - Get active sessions
- `TerminateSessionEvent` - Kill session

#### States
- `AuthInitial` - Initial state
- `AuthLoading` - Loading in progress
- `AuthAuthenticated` - User logged in
- `AuthUnauthenticated` - User logged out
- `AuthFailure` - Auth error
- `RegisterSuccess` - Registration complete
- `OTPVerified` - OTP verified
- `OTPResent` - OTP resent
- `TokenRefreshed` - Token refreshed
- `PasswordChanged` - Password updated
- `PasswordResetRequested` - Reset initiated
- `PasswordResetSuccess` - Reset complete
- `TwoFASent` - 2FA sent
- `TwoFAVerified` - 2FA verified
- `SessionsLoaded` - Sessions fetched
- `SessionTerminated` - Session killed

### 4. Login Flow UI

**Login Page Features:**
- Email validation (regex pattern)
- Password strength indicator
- Show/hide password toggle
- Remember me checkbox
- Forgot password link
- Real-time error display
- Secure password entry
- Device info collection

**OTP Verification Page Features:**
- 6-digit OTP input with auto-advance
- Countdown timer (5 minutes)
- Resend OTP button
- Masked contact display
- OTP expiration handling
- Security warnings

---

## Security Best Practices

### Backend Security

1. **Password Security**
   ```
   - Minimum 8 characters
   - Uppercase + lowercase + numbers + special characters
   - Bcrypt hashing with 10 rounds
   - Never store plain text passwords
   - Compare securely (constant-time)
   ```

2. **Token Security**
   ```
   - JWT with HS256 algorithm
   - Access token: 1 hour expiration
   - Refresh token: 7 days expiration
   - Session ID in token for validation
   - Token blacklisting on logout
   ```

3. **OTP Security**
   ```
   - 6-digit codes
   - 10-minute expiration
   - Single-use OTPs
   - Rate limited (3 per hour)
   - Secure random generation
   ```

4. **Account Lockout**
   ```
   - 5 failed attempts triggers lock
   - 30-minute lockout duration
   - Per-IP and per-email tracking
   - Auto-unlock after duration
   ```

5. **Rate Limiting**
   ```
   - Login: 5 attempts/30 min
   - OTP: 3 requests/hour
   - Password reset: 3 attempts/hour
   - API: Based on user role
   ```

### Flutter Security

1. **Token Storage**
   ```
   - Use flutter_secure_storage
   - Encrypted at rest
   - Platform-specific security:
     - Android: Keystore
     - iOS: Keychain
   - Never log tokens
   ```

2. **Network Security**
   ```
   - HTTPS only
   - Certificate pinning
   - Secure WebSocket (WSS)
   - No credentials in URL
   ```

3. **Data Protection**
   ```
   - Encrypt sensitive data
   - Clear clipboard after paste
   - Secure string handling
   - Clear sensitive logs
   ```

4. **Session Management**
   ```
   - Session ID in token
   - Device tracking
   - Multi-device support
   - Kill all sessions on password change
   ```

---

## Implementation Checklist

### Backend Setup
- [ ] Install required packages (jsonwebtoken, bcryptjs, pg-promise)
- [ ] Create database tables (users, otp_codes, user_sessions, login_attempts)
- [ ] Set up environment variables (JWT_SECRET, JWT_REFRESH_SECRET, etc.)
- [ ] Configure SMTP for email delivery
- [ ] Test OTP generation and delivery
- [ ] Implement session cleanup cron job
- [ ] Set up rate limiting cache (Redis recommended for production)
- [ ] Test all auth endpoints with Postman
- [ ] Implement monitoring and logging
- [ ] Setup error tracking (Sentry/New Relic)

### Flutter Setup
- [ ] Add flutter_secure_storage dependency
- [ ] Add device_info_plus for device detection
- [ ] Add dio for HTTP client
- [ ] Create secure storage service
- [ ] Implement auth repository
- [ ] Wire up BLoC with repository
- [ ] Create login/register pages
- [ ] Implement OTP verification page
- [ ] Add password reset flow
- [ ] Test on both Android and iOS
- [ ] Test token refresh
- [ ] Test logout behavior

### API Client Enhancements
- [ ] Add JWT interceptor
- [ ] Implement token refresh retry logic
- [ ] Add request signing (optional)
- [ ] Setup error handling
- [ ] Implement automatic logout on 401
- [ ] Add request/response logging

---

## Testing Strategy

### Backend Tests

**Unit Tests:**
```javascript
- Password validation and hashing
- OTP generation and expiration
- Token generation and verification
- Session creation and validation
- Rate limiting logic
- Account lockout logic
```

**Integration Tests:**
```javascript
- Registration flow (with email)
- Email OTP verification
- Login with 2FA
- Token refresh
- Password reset flow
- Session management
- Logout across sessions
```

### Flutter Tests

**Unit Tests:**
```dart
- Token storage encryption/decryption
- Auth state transitions
- Event handling
- Error handling
- Password validation
```

**Widget Tests:**
```dart
- Login form submission
- OTP input
- Error display
- Button enable/disable states
- Password toggle visibility
```

**Integration Tests:**
```dart
- Complete auth flow
- Token refresh seamlessness
- Session expiration handling
- Logout behavior
```

---

## Monitoring & Maintenance

### Key Metrics
- Failed login attempts per IP
- Average login time
- OTP delivery success rate
- Token refresh rate
- Session duration
- Account lockouts per day
- Password reset requests per day

### Logging
```javascript
// Log these events
- Registration attempts
- Login successes/failures
- OTP generation/verification
- Token refresh
- Account lockouts
- Session termination
- Password changes
- 2FA events
```

### Regular Maintenance
- [ ] Review and delete expired OTP codes (daily)
- [ ] Monitor failed login patterns (daily)
- [ ] Review active sessions (weekly)
- [ ] Update security policies (quarterly)
- [ ] Security audit (annually)
- [ ] Dependency updates (monthly)
- [ ] Rate limit rule reviews (quarterly)

---

## Troubleshooting

### Common Issues

**OTP Not Received**
- Check email configuration
- Verify SMTP credentials
- Check spam folder
- Verify email address is correct
- Check rate limiting thresholds

**Token Expired Errors**
- Token refresh logic should auto-trigger
- Check refresh token validity
- Verify token expiration times
- Check session validity

**Account Locked**
- Wait 30 minutes for auto-unlock
- Admin can manually unlock
- Check IP if using VPN
- Verify correct email/password

**Session Validation Fails**
- Clear local storage and re-login
- Check server time sync
- Verify session hasn't been terminated
- Check network connectivity

---

## Performance Optimization

1. **Caching**
   - Cache user sessions in Redis
   - Cache rate limit data
   - Cache OTP validation results

2. **Database**
   - Index on user.email
   - Index on session.user_id
   - Index on otp_codes.user_id
   - Composite index on login_attempts

3. **Rate Limiting**
   - Use Redis instead of in-memory
   - Implement sliding window
   - Cache rate limit decisions

4. **Token Handling**
   - Implement token blacklisting cache
   - Use short-lived access tokens
   - Refresh tokens securely

---

## Future Enhancements

1. **Biometric Authentication**
   - Fingerprint/Face recognition
   - Platform-specific implementation

2. **Social Login**
   - Google OAuth
   - Apple Sign-In
   - Facebook OAuth

3. **Advanced 2FA**
   - Authenticator apps (TOTP)
   - Security keys (FIDO2)
   - Backup codes

4. **Risk Analysis**
   - Unusual login detection
   - Device fingerprinting
   - Location-based alerts

5. **Compliance**
   - GDPR data retention
   - HIPAA compliance
   - PCI DSS for payments

---

## Support & Resources

- JWT Best Practices: https://tools.ietf.org/html/rfc8725
- OWASP Auth Cheatsheet: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- Flutter Security: https://flutter.dev/docs/security
- Node.js Security: https://nodejs.org/en/docs/guides/security/

