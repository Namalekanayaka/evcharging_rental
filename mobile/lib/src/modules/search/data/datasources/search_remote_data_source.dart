import 'package:dio/dio.dart';
import '../entities/search_entities.dart';

abstract class SearchRemoteDataSource {
  Future<List<ChargerSearchResultEntity>> searchNearbyChargers(
      SearchFilterEntity filters);
  Future<ChargerSearchResultEntity?> getRecommendedCharger(
      double latitude, double longitude,
      {int? batteryPercentage, bool urgentCharging});
  Future<List<ChargerSearchResultEntity>> searchByLocation(String query,
      {int limit, int offset});
  Future<AvailabilityEntity> getChargerAvailability(int chargerId);
  Future<List<ChargerSearchResultEntity>> getChargersInArea(
      double minLat, double maxLat, double minLng, double maxLng);
  Future<RouteInfoEntity> calculateRoute(
      double fromLat, double fromLng, double toLat, double toLng);
  Future<Map<String, dynamic>> advancedSearch(
      Map<String, dynamic> searchCriteria);
  Future<List<ChargerSearchResultEntity>> getTrendingChargers(
      {int limit, int radiusKm});
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final Dio _dio;
  final String baseUrl;

  SearchRemoteDataSourceImpl({
    required Dio dio,
    required this.baseUrl,
  }) : _dio = dio;

  @override
  Future<List<ChargerSearchResultEntity>> searchNearbyChargers(
      SearchFilterEntity filters) async {
    try {
      final response = await _dio.post(
        '$baseUrl/search/nearby',
        data: filters.toJson(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> chargersJson =
            response.data['data']['chargers'] ?? [];
        return chargersJson
            .map((json) => ChargerSearchResultEntity.fromJson(json))
            .toList();
      }

      throw Exception('Failed to search chargers: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Search request failed: ${e.message}');
    }
  }

  @override
  Future<ChargerSearchResultEntity?> getRecommendedCharger(
    double latitude,
    double longitude, {
    int? batteryPercentage,
    bool urgentCharging = false,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/search/recommend',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'batteryPercentage': batteryPercentage ?? 50,
          'urgentCharging': urgentCharging,
        },
      );

      if (response.statusCode == 200) {
        final charger = response.data['data']['charger'];
        if (charger != null) {
          return ChargerSearchResultEntity.fromJson(charger);
        }
        return null;
      }

      throw Exception('Failed to get recommendation: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Recommendation request failed: ${e.message}');
    }
  }

  @override
  Future<List<ChargerSearchResultEntity>> searchByLocation(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/search/location',
        queryParameters: {
          'q': query,
          'limit': limit,
          'offset': offset,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> chargersJson =
            response.data['data']['chargers'] ?? [];
        return chargersJson
            .map((json) => ChargerSearchResultEntity.fromJson(json))
            .toList();
      }

      throw Exception('Location search failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Location search request failed: ${e.message}');
    }
  }

  @override
  Future<AvailabilityEntity> getChargerAvailability(int chargerId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/search/chargers/$chargerId/availability',
      );

      if (response.statusCode == 200) {
        return AvailabilityEntity.fromJson(response.data['data']);
      }

      throw Exception('Failed to get availability: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Availability request failed: ${e.message}');
    }
  }

  @override
  Future<List<ChargerSearchResultEntity>> getChargersInArea(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/search/area',
        data: {
          'minLat': minLat,
          'maxLat': maxLat,
          'minLng': minLng,
          'maxLng': maxLng,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> chargersJson =
            response.data['data']['chargers'] ?? [];
        return chargersJson
            .map((json) => ChargerSearchResultEntity.fromJson(json))
            .toList();
      }

      throw Exception('Area search failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Area search request failed: ${e.message}');
    }
  }

  @override
  Future<RouteInfoEntity> calculateRoute(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/search/route',
        data: {
          'fromLat': fromLat,
          'fromLng': fromLng,
          'toLat': toLat,
          'toLng': toLng,
        },
      );

      if (response.statusCode == 200) {
        return RouteInfoEntity.fromJson(response.data['data']);
      }

      throw Exception('Route calculation failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Route request failed: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> advancedSearch(
      Map<String, dynamic> searchCriteria) async {
    try {
      final response = await _dio.post(
        '$baseUrl/search/advanced',
        data: searchCriteria,
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      }

      throw Exception('Advanced search failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Advanced search request failed: ${e.message}');
    }
  }

  @override
  Future<List<ChargerSearchResultEntity>> getTrendingChargers({
    int limit = 10,
    int radiusKm = 50,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/search/trending',
        queryParameters: {
          'limit': limit,
          'radiusKm': radiusKm,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> chargersJson =
            response.data['data']['chargers'] ?? [];
        return chargersJson
            .map((json) => ChargerSearchResultEntity.fromJson(json))
            .toList();
      }

      throw Exception('Trending search failed: ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Trending search request failed: ${e.message}');
    }
  }
}
