class SearchFilterEntity {
  final double? latitude;
  final double? longitude;
  final double radiusKm;
  final double minPrice;
  final double maxPrice;
  final List<String> chargerTypes;
  final int minPower;
  final bool availability;
  final String sortBy;
  final int limit;
  final int offset;

  SearchFilterEntity({
    this.latitude,
    this.longitude,
    this.radiusKm = 10,
    this.minPrice = 0,
    this.maxPrice = 100,
    this.chargerTypes = const [],
    this.minPower = 0,
    this.availability = true,
    this.sortBy = 'distance',
    this.limit = 20,
    this.offset = 0,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radiusKm,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'chargerTypes': chargerTypes,
        'minPower': minPower,
        'availability': availability,
        'sortBy': sortBy,
        'limit': limit,
        'offset': offset,
      };

  SearchFilterEntity copyWith({
    double? latitude,
    double? longitude,
    double? radiusKm,
    double? minPrice,
    double? maxPrice,
    List<String>? chargerTypes,
    int? minPower,
    bool? availability,
    String? sortBy,
    int? limit,
    int? offset,
  }) {
    return SearchFilterEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      chargerTypes: chargerTypes ?? this.chargerTypes,
      minPower: minPower ?? this.minPower,
      availability: availability ?? this.availability,
      sortBy: sortBy ?? this.sortBy,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}

class ChargerSearchResultEntity {
  final int id;
  final String locationName;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String chargerType;
  final int powerOutput;
  final double pricePerKwh;
  final double rating;
  final String ownerName;
  final String? ownerProfilePicture;
  final int totalPorts;
  final int availablePorts;
  final int activeBookings;
  final double distanceKm;
  final String status;

  ChargerSearchResultEntity({
    required this.id,
    required this.locationName,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.chargerType,
    required this.powerOutput,
    required this.pricePerKwh,
    required this.rating,
    required this.ownerName,
    this.ownerProfilePicture,
    required this.totalPorts,
    required this.availablePorts,
    required this.activeBookings,
    required this.distanceKm,
    required this.status,
  });

  factory ChargerSearchResultEntity.fromJson(Map<String, dynamic> json) {
    return ChargerSearchResultEntity(
      id: json['id'] as int,
      locationName: json['location_name'] as String? ?? 'Unknown',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      chargerType: json['charger_type'] as String? ?? 'Unknown',
      powerOutput: json['power_output'] as int? ?? 0,
      pricePerKwh: (json['price_per_kwh'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      ownerName: json['owner_name'] as String? ?? 'Unknown',
      ownerProfilePicture: json['profile_picture'] as String?,
      totalPorts: json['total_ports'] as int? ?? 1,
      availablePorts: json['available_ports'] as int? ?? 0,
      activeBookings: json['active_bookings'] as int? ?? 0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'location_name': locationName,
        'address': address,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'charger_type': chargerType,
        'power_output': powerOutput,
        'price_per_kwh': pricePerKwh,
        'rating': rating,
        'owner_name': ownerName,
        'profile_picture': ownerProfilePicture,
        'total_ports': totalPorts,
        'available_ports': availablePorts,
        'active_bookings': activeBookings,
        'distance_km': distanceKm,
        'status': status,
      };
}

class RouteInfoEntity {
  final double distanceKm;
  final int estimatedMinutes;
  final String estimatedTime;

  RouteInfoEntity({
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.estimatedTime,
  });

  factory RouteInfoEntity.fromJson(Map<String, dynamic> json) {
    return RouteInfoEntity(
      distanceKm: (json['distanceKm'] as num).toDouble(),
      estimatedMinutes: json['estimatedMinutes'] as int,
      estimatedTime: json['estimatedTime'] as String,
    );
  }
}

class AvailabilityEntity {
  final int id;
  final int totalPorts;
  final int occupiedPorts;
  final int availablePorts;
  final List<dynamic>? currentBookings;
  final String status;
  final DateTime? lastMaintenance;

  AvailabilityEntity({
    required this.id,
    required this.totalPorts,
    required this.occupiedPorts,
    required this.availablePorts,
    this.currentBookings,
    required this.status,
    this.lastMaintenance,
  });

  factory AvailabilityEntity.fromJson(Map<String, dynamic> json) {
    return AvailabilityEntity(
      id: json['id'] as int,
      totalPorts: json['total_ports'] as int,
      occupiedPorts: json['occupied_ports'] as int? ?? 0,
      availablePorts: json['available_ports'] as int? ?? 0,
      currentBookings: json['current_bookings'] as List?,
      status: json['status'] as String? ?? 'active',
      lastMaintenance: json['last_maintenance'] != null
          ? DateTime.parse(json['last_maintenance'] as String)
          : null,
    );
  }
}
