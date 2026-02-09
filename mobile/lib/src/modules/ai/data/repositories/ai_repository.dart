import 'package:dartz/dartz.dart';
import '../../domain/entities/ai_entities.dart';
import '../datasources/ai_remote_data_source.dart';
import '../../../../../core/error/failures.dart';

abstract class AIRepository {
  Future<Either<Failure, BatteryRangeEntity>> predictBatteryRange(
    String carModel,
    double currentBattery, {
    String? weather,
  });
  Future<Either<Failure, List<ChargerRecommendationEntity>>>
      findNearestChargers(
    double latitude,
    double longitude,
    double currentBattery,
    String carModel, {
    String? weather,
  });
  Future<Either<Failure, DemandPricingEntity>> predictDemandPricing(
    int chargerId, {
    String? dateTime,
  });
  Future<Either<Failure, OptimizedRouteEntity>> optimizeRoute(
    List<Map<String, dynamic>> locations,
    String carModel,
    double currentBattery, {
    String? weather,
  });
  Future<Either<Failure, List<AIRecommendationEntity>>> getRecommendations();
}

class AIRepositoryImpl implements AIRepository {
  final AIRemoteDataSource remoteDataSource;

  AIRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BatteryRangeEntity>> predictBatteryRange(
    String carModel,
    double currentBattery, {
    String? weather,
  }) async {
    try {
      final result = await remoteDataSource.predictBatteryRange(
        carModel,
        currentBattery,
        weather: weather,
      );
      return Right(_mapBatteryRangeEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChargerRecommendationEntity>>>
      findNearestChargers(
    double latitude,
    double longitude,
    double currentBattery,
    String carModel, {
    String? weather,
  }) async {
    try {
      final result = await remoteDataSource.findNearestChargers(
        latitude,
        longitude,
        currentBattery,
        carModel,
        weather: weather,
      );
      return Right(result.map(_mapChargerRecommendationEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DemandPricingEntity>> predictDemandPricing(
    int chargerId, {
    String? dateTime,
  }) async {
    try {
      final result = await remoteDataSource.predictDemandPricing(
        chargerId,
        dateTime: dateTime,
      );
      return Right(_mapDemandPricingEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OptimizedRouteEntity>> optimizeRoute(
    List<Map<String, dynamic>> locations,
    String carModel,
    double currentBattery, {
    String? weather,
  }) async {
    try {
      final result = await remoteDataSource.optimizeRoute(
        locations,
        carModel,
        currentBattery,
        weather: weather,
      );
      return Right(_mapOptimizedRouteEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AIRecommendationEntity>>>
      getRecommendations() async {
    try {
      final result = await remoteDataSource.getRecommendations();
      return Right(result.map(_mapRecommendationEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // Mapping functions
  BatteryRangeEntity _mapBatteryRangeEntity(Map<String, dynamic> json) {
    return BatteryRangeEntity(
      predictedRange: (json['predictedRange'] as num).toInt(),
      currentBattery: (json['currentBattery'] as num).toDouble(),
      fullChargeRange: (json['fullChargeRange'] as num).toInt(),
      weatherFactor: json['weatherFactor'] as String,
      efficiency: (json['efficiency'] as num).toDouble(),
    );
  }

  ChargerRecommendationEntity _mapChargerRecommendationEntity(
      Map<String, dynamic> json) {
    return ChargerRecommendationEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      location: json['location'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      pricePerKwh: (json['price_per_kwh'] as num).toDouble(),
      chargerType: json['charger_type'] as String,
      isAvailable: json['is_available'] as bool,
      avgRating: json['avg_rating'] != null
          ? (json['avg_rating'] as num).toDouble()
          : null,
      reviewCount: json['review_count'] as int?,
      activeBookings: json['active_bookings'] as int?,
      distanceKm: (json['distance_km'] as num).toDouble(),
      score: (json['score'] as num).toInt(),
      willReachWithBuffer: json['willReachWithBuffer'] as bool,
    );
  }

  DemandPricingEntity _mapDemandPricingEntity(Map<String, dynamic> json) {
    return DemandPricingEntity(
      currentPrice: (json['currentPrice'] as num).toDouble(),
      predictedPrice: (json['predictedPrice'] as num).toDouble(),
      demandMultiplier: (json['demandMultiplier'] as num).toDouble(),
      demandLevel: json['demandLevel'] as String,
      hour: (json['hour'] as num).toInt(),
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      forecastedOccupancy: (json['forecastedOccupancy'] as num).toInt(),
    );
  }

  OptimizedRouteEntity _mapOptimizedRouteEntity(Map<String, dynamic> json) {
    return OptimizedRouteEntity(
      optimizedRoute: (json['optimizedRoute'] as List)
          .map((e) => _mapRouteStopEntity(e as Map<String, dynamic>))
          .toList(),
      totalTimeMinutes: (json['totalTimeMinutes'] as num).toInt(),
      waypoints: (json['waypoints'] as num).toInt(),
      efficiency: json['efficiency'] as String,
    );
  }

  RouteStopEntity _mapRouteStopEntity(Map<String, dynamic> json) {
    return RouteStopEntity(
      type: json['type'] as String,
      charger: json['charger'] != null
          ? _mapChargerRecommendationEntity(
              json['charger'] as Map<String, dynamic>)
          : null,
      chargingTimeMinutes: json['chargingTimeMinutes'] as int?,
      arrivalBattery: json['arrivalBattery'] as int?,
    );
  }

  AIRecommendationEntity _mapRecommendationEntity(Map<String, dynamic> json) {
    return AIRecommendationEntity(
      type: json['type'] as String,
      message: json['message'] as String,
      priority: json['priority'] as String,
    );
  }
}
