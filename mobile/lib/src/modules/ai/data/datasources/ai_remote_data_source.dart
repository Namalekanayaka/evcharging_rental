import 'package:dio/dio.dart';

abstract class AIRemoteDataSource {
  Future<Map<String, dynamic>> predictBatteryRange(
    String carModel,
    double currentBattery, {
    String? weather,
  });
  Future<List<Map<String, dynamic>>> findNearestChargers(
    double latitude,
    double longitude,
    double currentBattery,
    String carModel, {
    String? weather,
  });
  Future<Map<String, dynamic>> predictDemandPricing(
    int chargerId, {
    String? dateTime,
  });
  Future<Map<String, dynamic>> optimizeRoute(
    List<Map<String, dynamic>> locations,
    String carModel,
    double currentBattery, {
    String? weather,
  });
  Future<List<Map<String, dynamic>>> getRecommendations();
}

class AIRemoteDataSourceImpl implements AIRemoteDataSource {
  final Dio dio;
  static const String baseUrl = '/api/ai';

  AIRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> predictBatteryRange(
    String carModel,
    double currentBattery, {
    String? weather,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/battery-range',
        data: {
          'carModel': carModel,
          'currentBattery': currentBattery,
          'weather': weather ?? 'normal',
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> findNearestChargers(
    double latitude,
    double longitude,
    double currentBattery,
    String carModel, {
    String? weather,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/nearest-chargers',
        data: {
          'userLocation': {
            'latitude': latitude,
            'longitude': longitude,
          },
          'currentBattery': currentBattery,
          'carModel': carModel,
          'weather': weather ?? 'normal',
        },
      );
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> predictDemandPricing(
    int chargerId, {
    String? dateTime,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/demand-pricing/$chargerId',
        queryParameters: {
          if (dateTime != null) 'dateTime': dateTime,
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> optimizeRoute(
    List<Map<String, dynamic>> locations,
    String carModel,
    double currentBattery, {
    String? weather,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/optimize-route',
        data: {
          'locations': locations,
          'carModel': carModel,
          'currentBattery': currentBattery,
          'weather': weather ?? 'normal',
        },
      );
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecommendations() async {
    try {
      final response = await dio.get('$baseUrl/recommendations');
      final list = response.data['data'] as List;
      return list.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException error) {
    if (error.response?.statusCode == 404) {
      return 'Resource not found';
    } else if (error.response?.statusCode == 401) {
      return 'Unauthorized access';
    } else if (error.response?.statusCode == 400) {
      return error.response?.data['error'] ?? 'Bad request';
    }
    return error.message ?? 'AI service error';
  }
}
