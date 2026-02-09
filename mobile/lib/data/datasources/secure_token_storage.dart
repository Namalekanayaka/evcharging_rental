import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Token Storage Service
/// Stores JWT tokens securely using flutter_secure_storage
class SecureTokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _sessionIdKey = 'session_id';
  static const String _userIdKey = 'user_id';
  static const String _deviceInfoKey = 'device_info';

  final FlutterSecureStorage _secureStorage;

  SecureTokenStorage({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: _refreshTokenKey,
      value: token,
    );
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// Save session ID
  Future<void> saveSessionId(String sessionId) async {
    await _secureStorage.write(
      key: _sessionIdKey,
      value: sessionId,
    );
  }

  /// Get session ID
  Future<String?> getSessionId() async {
    return await _secureStorage.read(key: _sessionIdKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(
      key: _userIdKey,
      value: userId,
    );
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// Save device info
  Future<void> saveDeviceInfo(String deviceInfo) async {
    await _secureStorage.write(
      key: _deviceInfoKey,
      value: deviceInfo,
    );
  }

  /// Get device info
  Future<String?> getDeviceInfo() async {
    return await _secureStorage.read(key: _deviceInfoKey);
  }

  /// Save all tokens and session info
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String sessionId,
    required String userId,
    String? deviceInfo,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveSessionId(sessionId),
      saveUserId(userId),
      if (deviceInfo != null) saveDeviceInfo(deviceInfo),
    ]);
  }

  /// Get all stored auth data
  Future<Map<String, String?>> getAuthData() async {
    return {
      'accessToken': await getAccessToken(),
      'refreshToken': await getRefreshToken(),
      'sessionId': await getSessionId(),
      'userId': await getUserId(),
      'deviceInfo': await getDeviceInfo(),
    };
  }

  /// Check if user is authenticated (has tokens)
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all tokens and auth data (logout)
  Future<void> clearAuthData() async {
    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _sessionIdKey),
      _secureStorage.delete(key: _userIdKey),
      _secureStorage.delete(key: _deviceInfoKey),
    ]);
  }

  /// Clear only access token (for testing token refresh)
  Future<void> clearAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }

  /// Check token expiration
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = _decodeBase64(parts[1]);
      final json = payload;

      final exp = json['exp'] as int?;
      if (exp == null) return true;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now > exp;
    } catch (e) {
      return true;
    }
  }

  /// Decode base64 JWT payload
  Map<String, dynamic> _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!');
    }

    // For now, return empty map - in production, decode JSON from base64
    return {};
  }
}
