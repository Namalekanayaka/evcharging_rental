import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class ApiClient {
  late final Dio _dio;
  late final String _token;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(milliseconds: connectionTimeout),
        receiveTimeout: const Duration(milliseconds: receiveTimeout),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _token = token;
  }

  // Generic HTTP Methods
  Future<Response> post(
    String endpoint, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(
      endpoint,
      queryParameters: queryParameters,
    );
  }

  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? data,
  }) {
    return _dio.delete(
      endpoint,
      data: data,
    );
  }

  Future<Response> put(
    String endpoint, {
    required Map<String, dynamic> data,
  }) {
    return _dio.put(endpoint, data: data);
  }

  Future<Response> patch(
    String endpoint, {
    required Map<String, dynamic> data,
  }) {
    return _dio.patch(endpoint, data: data);
  }

  // Auth APIs
  Future<Response> register(Map<String, dynamic> data) {
    return _dio.post('/auth/register', data: data);
  }

  Future<Response> verifyOTP(String userId, String otp) {
    return _dio.post('/auth/verify-otp', data: {'userId': userId, 'otp': otp});
  }

  Future<Response> login(String email, String password) {
    return _dio
        .post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<Response> resendOTP(String email) {
    return _dio.post('/auth/resend-otp', data: {'email': email});
  }

  // User APIs
  Future<Response> getUserProfile() {
    return _dio.get('/users/profile');
  }

  Future<Response> updateProfile(Map<String, dynamic> data) {
    return _dio.put('/users/profile', data: data);
  }

  // Charger APIs
  Future<Response> searchChargers(Map<String, dynamic> params) {
    return _dio.get('/chargers/search', queryParameters: params);
  }

  Future<Response> getChargerDetail(int chargerId) {
    return _dio.get('/chargers/$chargerId');
  }

  Future<Response> createCharger(Map<String, dynamic> data) {
    return _dio.post('/chargers', data: data);
  }

  // Booking APIs
  Future<Response> createBooking(Map<String, dynamic> data) {
    return _dio.post('/bookings', data: data);
  }

  Future<Response> getBookings() {
    return _dio.get('/bookings');
  }

  Future<Response> getBookingDetail(int bookingId) {
    return _dio.get('/bookings/$bookingId');
  }

  Future<Response> cancelBooking(int bookingId, String reason) {
    return _dio.patch('/bookings/$bookingId/cancel', data: {'reason': reason});
  }

  // Wallet APIs
  Future<Response> getWallet() {
    return _dio.get('/wallet');
  }

  Future<Response> addBalance(double amount) {
    return _dio.post('/wallet/add-balance', data: {'amount': amount});
  }

  // Payment APIs
  Future<Response> processPayment(Map<String, dynamic> data) {
    return _dio.post('/payments', data: data);
  }

  // Review APIs
  Future<Response> createReview(Map<String, dynamic> data) {
    return _dio.post('/reviews', data: data);
  }

  Future<Response> getChargerReviews(int chargerId) {
    return _dio.get('/reviews/charger/$chargerId');
  }
}
