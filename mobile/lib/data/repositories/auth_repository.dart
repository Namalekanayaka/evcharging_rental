import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../../domain/entities/user_entity.dart';
import '../datasource/api_client.dart';
import '../datasources/secure_token_storage.dart';

/// Authentication Repository
/// Handles authentication logic and token management
class AuthRepository {
  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;
  final DeviceInfoPlugin _deviceInfo;

  AuthRepository({
    required ApiClient apiClient,
    required SecureTokenStorage tokenStorage,
    DeviceInfoPlugin? deviceInfo,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage,
        _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  /// Get device identifier
  Future<String> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.systemName} ${iosInfo.model}';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'phone': phone,
          'password': password,
          'confirmPassword': confirmPassword,
          'firstName': firstName,
          'lastName': lastName,
          'userType': userType,
        },
      );

      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Verify email OTP
  Future<UserEntity> verifyEmailOTP({
    required int userId,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-email-otp',
        data: {
          'userId': userId,
          'otp': otp,
        },
      );

      final data = response.data['data'];
      return UserEntity.fromJson(data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// Verify phone OTP
  Future<UserEntity> verifyPhoneOTP({
    required int userId,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-phone-otp',
        data: {
          'userId': userId,
          'otp': otp,
        },
      );

      final data = response.data['data'];
      return UserEntity.fromJson(data['user']);
    } catch (e) {
      rethrow;
    }
  }

  /// Enhanced login with token and session storage
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final deviceInfo = await _getDeviceInfo();

      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'deviceInfo': deviceInfo,
        },
      );

      final data = response.data['data'];
      final tokens = data['tokens'];
      final session = data['session'];

      // Save tokens and session securely
      await _tokenStorage.saveAuthData(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
        sessionId: session['sessionId'],
        userId: data['user']['id'].toString(),
        deviceInfo: deviceInfo,
      );

      return data;
    } catch (e) {
      rethrow;
    }
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOTP({
    required int userId,
    required String contact,
    String type = 'email',
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/resend-otp',
        data: {
          'userId': userId,
          'contact': contact,
          'type': type,
        },
      );

      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  /// Refresh access token
  Future<String> refreshAccessToken() async {
    try {
      final userId = await _tokenStorage.getUserId();
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (userId == null || refreshToken == null) {
        throw Exception('No refresh token available');
      }

      final response = await _apiClient.post(
        '/auth/refresh-token',
        data: {'userId': userId, 'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['data']['accessToken'];
      await _tokenStorage.saveAccessToken(newAccessToken);

      return newAccessToken;
    } catch (e) {
      // Clear auth on refresh failure
      await _tokenStorage.clearAuthData();
      rethrow;
    }
  }

  /// Logout
  Future<void> logout({bool allDevices = false}) async {
    try {
      final sessionId = await _tokenStorage.getSessionId();

      await _apiClient.post(
        '/auth/logout',
        data: {
          'sessionId': sessionId,
          'allDevices': allDevices,
        },
      );
    } finally {
      // Clear local storage regardless of API call result
      await _tokenStorage.clearAuthData();
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      // Clear tokens after password change
      await _tokenStorage.clearAuthData();
    } catch (e) {
      rethrow;
    }
  }

  /// Request password reset
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _apiClient.post(
        '/auth/request-password-reset',
        data: {'email': email},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password with OTP
  Future<void> resetPassword({
    required int userId,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.post(
        '/auth/reset-password',
        data: {
          'userId': userId,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Send 2FA code
  Future<void> send2FA({String method = 'email'}) async {
    try {
      await _apiClient.post(
        '/auth/send-2fa',
        data: {'method': method},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verify 2FA code
  Future<void> verify2FA({
    required String code,
    String method = 'email',
  }) async {
    try {
      await _apiClient.post(
        '/auth/verify-2fa',
        data: {
          'code': code,
          'method': method,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get user sessions
  Future<List<Map<String, dynamic>>> getUserSessions() async {
    try {
      final response = await _apiClient.get('/auth/sessions');
      final sessions = (response.data['data'] as List)
          .map((session) => session as Map<String, dynamic>)
          .toList();
      return sessions;
    } catch (e) {
      rethrow;
    }
  }

  /// Terminate session
  Future<void> terminateSession({required String sessionId}) async {
    try {
      await _apiClient.delete('/auth/sessions/$sessionId');
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenStorage.isAuthenticated();
  }

  /// Get stored user data
  Future<Map<String, String?>> getAuthData() async {
    return await _tokenStorage.getAuthData();
  }

  /// Clear authentication data
  Future<void> clearAuthData() async {
    await _tokenStorage.clearAuthData();
  }
}
