import 'package:dio/dio.dart';

abstract class PricingRemoteDataSource {
  Future<List<Map<String, dynamic>>> getPricingPackages();
  Future<Map<String, dynamic>> getUserSubscription();
  Future<Map<String, dynamic>> subscribeToPackage(
      int packageId, String billingCycle);
  Future<Map<String, dynamic>> cancelSubscription();
  Future<Map<String, dynamic>> getDynamicPrice(
      int chargerId, String demandLevel);
  Future<List<Map<String, dynamic>>> getPricingHistory(int chargerId, int days);
  Future<List<Map<String, dynamic>>> getCommissionBreakdown(
      int? month, int? year);
}

class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final Dio dio;
  static const String baseUrl = '/api/pricing';

  PricingRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getPricingPackages() async {
    try {
      final response = await dio.get('$baseUrl/packages');
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getUserSubscription() async {
    try {
      final response = await dio.get('$baseUrl/subscription');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> subscribeToPackage(
      int packageId, String billingCycle) async {
    try {
      final response = await dio.post(
        '$baseUrl/subscribe',
        data: {
          'packageId': packageId,
          'billingCycle': billingCycle,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final response = await dio.post('$baseUrl/cancel-subscription');
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDynamicPrice(
      int chargerId, String demandLevel) async {
    try {
      final response = await dio.get(
        '$baseUrl/dynamic-price/$chargerId',
        queryParameters: {'demandLevel': demandLevel},
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPricingHistory(
      int chargerId, int days) async {
    try {
      final response = await dio.get(
        '$baseUrl/history/$chargerId',
        queryParameters: {'days': days},
      );
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCommissionBreakdown(
      int? month, int? year) async {
    try {
      final response = await dio.get(
        '$baseUrl/commission',
        queryParameters: {
          if (month != null) 'month': month,
          if (year != null) 'year': year,
        },
      );
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return 'Resource not found';
    }
    if (e.response?.statusCode == 400) {
      return e.response?.data['message'] ?? 'Bad request';
    }
    return e.message ?? 'Unknown error occurred';
  }
}
