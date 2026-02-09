import 'package:dio/dio.dart';

abstract class AdminRemoteDataSource {
  Future<List<Map<String, dynamic>>> getUsers(int limit, int offset, {Map<String, dynamic>? filters});
  Future<Map<String, dynamic>> toggleUserSuspension(int userId, bool suspend);
  Future<List<Map<String, dynamic>>> getChargers(int limit, int offset, {Map<String, dynamic>? filters});
  Future<Map<String, dynamic>> approveCharger(int chargerId, bool approved, {String? reason});
  Future<List<Map<String, dynamic>>> getRevenueAnalytics(String startDate, String endDate);
  Future<Map<String, dynamic>> getPlatformAnalytics();
  Future<List<Map<String, dynamic>>> getFraudCases(int limit, int offset);
  Future<Map<String, dynamic>> resolveFraudCase(int caseId, String resolution, {String? notes});
  Future<Map<String, dynamic>> createPromotion(Map<String, dynamic> promotionData);
  Future<List<Map<String, dynamic>>> getPromotions(int limit, int offset);
  Future<List<Map<String, dynamic>>> getTopChargers(int limit);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final Dio dio;
  static const String baseUrl = '/api/admin';

  AdminRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getUsers(
    int limit,
    int offset, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        ...?filters,
      };
      final response = await dio.get('$baseUrl/users', queryParameters: queryParams);
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> toggleUserSuspension(int userId, bool suspend) async {
    try {
      final response = await dio.post(
        '$baseUrl/users/$userId/suspend',
        data: {'suspend': suspend},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getChargers(
    int limit,
    int offset, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        ...?filters,
      };
      final response = await dio.get('$baseUrl/chargers', queryParameters: queryParams);
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> approveCharger(
    int chargerId,
    bool approved, {
    String? reason,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/chargers/$chargerId/approve',
        data: {
          'approved': approved,
          'reason': reason ?? '',
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueAnalytics(
    String startDate,
    String endDate,
  ) async {
    try {
      final response = await dio.get(
        '$baseUrl/analytics/revenue',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getPlatformAnalytics() async {
    try {
      final response = await dio.get('$baseUrl/analytics/summary');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getFraudCases(int limit, int offset) async {
    try {
      final response = await dio.get(
        '$baseUrl/fraud/cases',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> resolveFraudCase(
    int caseId,
    String resolution, {
    String? notes,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/fraud/cases/$caseId/resolve',
        data: {
          'resolution': resolution,
          'notes': notes ?? '',
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> createPromotion(Map<String, dynamic> promotionData) async {
    try {
      final response = await dio.post(
        '$baseUrl/promotions',
        data: promotionData,
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPromotions(int limit, int offset) async {
    try {
      final response = await dio.get(
        '$baseUrl/promotions',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getTopChargers(int limit) async {
    try {
      final response = await dio.get(
        '$baseUrl/analytics/top-chargers',
        queryParameters: {'limit': limit},
      );
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Unauthorized - admin access required';
    } else if (error.response?.statusCode == 403) {
      return 'Forbidden - insufficient permissions';
    } else if (error.response?.statusCode == 404) {
      return 'Resource not found';
    }
    return error.message ?? 'Admin service error';
  }
}
