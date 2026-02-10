import '../../domain/entities/charger_entity.dart';
import '../../core/constants/api_constants.dart';
import '../datasource/api_client.dart';

/// Charger Repository
/// Handles charger data operations and API communication
class ChargerRepository {
  final ApiClient _apiClient;

  ChargerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Search chargers with filters
  Future<Map<String, dynamic>> searchChargers({
    double? latitude,
    double? longitude,
    double? radius,
    double? minPrice,
    double? maxPrice,
    String? chargerType,
    String? city,
    String? sortBy = 'DISTANCE',
    int page = 1,
  }) async {
    // MOCK DATA Handling
    if (useMockData) {
      final mockChargers = List.generate(10, (index) => ChargerEntity(
        id: index + 1,
        ownerId: 1,
        name: 'Mock Charger ${index + 1}',
        description: 'This is a mock charger for testing purposes.',
        type: 'LEVEL_2',
        address: '123 Mock Street',
        latitude: latitude ?? 37.7749 + (index * 0.01),
        longitude: longitude ?? -122.4194 + (index * 0.01),
        pricePerHour: 10.0 + index,
        connectorTypes: ['J1772', 'CCS'],
        maxWattage: 7.2,
        averageRating: 4.5,
        totalReviews: 10,
        status: 'AVAILABLE',
        createdAt: DateTime.now(),
      ));

      return {
        'chargers': mockChargers,
        'totalCount': 10,
        'page': page,
      };
    }

    try {
      final params = <String, dynamic>{
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (chargerType != null) 'chargerType': chargerType,
        if (city != null) 'city': city,
        'sortBy': sortBy,
        'page': page,
      };

      final response = await _apiClient.get(
        '/chargers/search',
        queryParameters: params,
      );

      final data = response.data['data'];
      final chargers = (data['chargers'] as List)
          .map((c) => ChargerEntity(
            id: c['id'],
            ownerId: c['ownerId'],
            name: c['name'],
            description: c['description'],
            type: c['type'],
            address: c['address'],
            latitude: c['latitude'],
            longitude: c['longitude'],
            pricePerHour: c['pricePerHour'],
            connectorTypes: List<String>.from(c['connectorTypes'] ?? []),
            maxWattage: c['maxWattage'],
            averageRating: c['averageRating'],
            totalReviews: c['totalReviews'],
            status: c['status'],
            createdAt: DateTime.parse(c['createdAt']),
          ))
          .toList();

      return {
        'chargers': chargers,
        'totalCount': data['totalCount'],
        'page': page,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get charger details
  Future<ChargerEntity> getChargerDetail(int chargerId) async {
    // MOCK DATA Handling
    if (useMockData) {
      return ChargerEntity(
        id: chargerId,
        ownerId: 1,
        name: 'Mock Charger $chargerId',
        description: 'Details for mock charger $chargerId. This is a level 2 charger with high availability.',
        type: 'LEVEL_2',
        address: '123 Mock Street, Tech City',
        latitude: 37.7749,
        longitude: -122.4194,
        pricePerHour: 15.0,
        connectorTypes: ['J1772', 'CCS', 'CHAdeMO'],
        maxWattage: 11.0,
        averageRating: 4.8,
        totalReviews: 25,
        status: 'AVAILABLE',
        createdAt: DateTime.now(),
      );
    }
    
    try {
      final response = await _apiClient.get('/chargers/$chargerId');
      final data = response.data['data'];

      return ChargerEntity(
        id: data['id'],
        ownerId: data['ownerId'],
        name: data['name'],
        description: data['description'],
        type: data['type'],
        address: data['address'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        pricePerHour: data['pricePerHour'],
        connectorTypes: List<String>.from(data['connectorTypes'] ?? []),
        maxWattage: data['maxWattage'],
        averageRating: data['averageRating'],
        totalReviews: data['totalReviews'],
        status: data['status'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Create new charger
  Future<ChargerEntity> createCharger({
    required String name,
    required String description,
    required String type,
    required String address,
    required String city,
    required String state,
    required String postalCode,
    required double latitude,
    required double longitude,
    required double pricePerKwh,
    required double pricePerHour,
    required double powerKw,
    required bool isPublic,
    required bool allowReservations,
  }) async {
    try {
      final response = await _apiClient.post(
        '/chargers',
        data: {
          'name': name,
          'description': description,
          'type': type,
          'address': address,
          'city': city,
          'state': state,
          'postalCode': postalCode,
          'latitude': latitude,
          'longitude': longitude,
          'pricePerKwh': pricePerKwh,
          'pricePerHour': pricePerHour,
          'powerKw': powerKw,
          'isPublic': isPublic,
          'allowReservations': allowReservations,
        },
      );

      final data = response.data['data'];
      return ChargerEntity(
        id: data['id'],
        ownerId: data['ownerId'],
        name: data['name'],
        description: data['description'],
        type: data['type'],
        address: data['address'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        pricePerHour: data['pricePerHour'],
        connectorTypes: List<String>.from(data['connectorTypes'] ?? []),
        maxWattage: data['maxWattage'],
        averageRating: data['averageRating'],
        totalReviews: data['totalReviews'],
        status: data['status'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Update charger
  Future<ChargerEntity> updateCharger({
    required int chargerId,
    required String name,
    required String description,
    required String type,
    required String address,
    required String city,
    required String state,
    required String postalCode,
    required double latitude,
    required double longitude,
    required double pricePerKwh,
    required double pricePerHour,
    required double powerKw,
    required bool isPublic,
    required bool allowReservations,
  }) async {
    try {
      final response = await _apiClient.put(
        '/chargers/$chargerId',
        data: {
          'name': name,
          'description': description,
          'type': type,
          'address': address,
          'city': city,
          'state': state,
          'postalCode': postalCode,
          'latitude': latitude,
          'longitude': longitude,
          'pricePerKwh': pricePerKwh,
          'pricePerHour': pricePerHour,
          'powerKw': powerKw,
          'isPublic': isPublic,
          'allowReservations': allowReservations,
        },
      );

      final data = response.data['data'];
      return ChargerEntity(
        id: data['id'],
        ownerId: data['ownerId'],
        name: data['name'],
        description: data['description'],
        type: data['type'],
        address: data['address'],
        latitude: data['latitude'],
        longitude: data['longitude'],
        pricePerHour: data['pricePerHour'],
        connectorTypes: List<String>.from(data['connectorTypes'] ?? []),
        maxWattage: data['maxWattage'],
        averageRating: data['averageRating'],
        totalReviews: data['totalReviews'],
        status: data['status'],
        createdAt: DateTime.parse(data['createdAt']),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Delete charger
  Future<void> deleteCharger(int chargerId) async {
    try {
      await _apiClient.delete('/chargers/$chargerId');
    } catch (e) {
      rethrow;
    }
  }

  /// Get operator's chargers
  Future<List<ChargerEntity>> getMyChargers() async {
    try {
      final response = await _apiClient.get('/chargers/my-chargers');
      final chargers = (response.data['data']['chargers'] as List)
          .map((c) => ChargerEntity(
            id: c['id'],
            ownerId: c['ownerId'],
            name: c['name'],
            description: c['description'],
            type: c['type'],
            address: c['address'],
            latitude: c['latitude'],
            longitude: c['longitude'],
            pricePerHour: c['pricePerHour'],
            connectorTypes: List<String>.from(c['connectorTypes'] ?? []),
            maxWattage: c['maxWattage'],
            averageRating: c['averageRating'],
            totalReviews: c['totalReviews'],
            status: c['status'],
            createdAt: DateTime.parse(c['createdAt']),
          ))
          .toList();
      return chargers;
    } catch (e) {
      rethrow;
    }
  }

  /// Update charger status
  Future<void> updateChargerStatus(int chargerId, String status) async {
    try {
      await _apiClient.patch(
        '/chargers/$chargerId/status',
        data: {'status': status},
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get charger usage history
  Future<Map<String, dynamic>> getChargerUsageHistory({
    required int chargerId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final params = <String, dynamic>{
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/chargers/$chargerId/usage-history',
        queryParameters: params,
      );

      final data = response.data['data'];
      return {
        'usageHistory': data['usageHistory'] ?? [],
        'totalRevenue': data['totalRevenue'] ?? 0.0,
        'totalBookings': data['totalBookings'] ?? 0,
      };
    } catch (e) {
      rethrow;
    }
  }
}
