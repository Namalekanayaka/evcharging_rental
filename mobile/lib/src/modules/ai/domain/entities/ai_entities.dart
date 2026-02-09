import 'package:equatable/equatable.dart';

/// AI Battery Range Prediction Entity
class BatteryRangeEntity extends Equatable {
  final int predictedRange;
  final double currentBattery;
  final int fullChargeRange;
  final String weatherFactor;
  final double efficiency;

  const BatteryRangeEntity({
    required this.predictedRange,
    required this.currentBattery,
    required this.fullChargeRange,
    required this.weatherFactor,
    required this.efficiency,
  });

  @override
  List<Object?> get props => [
    predictedRange,
    currentBattery,
    fullChargeRange,
    weatherFactor,
    efficiency,
  ];
}

/// AI Charger Recommendation Entity
class ChargerRecommendationEntity extends Equatable {
  final int id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final double pricePerKwh;
  final String chargerType;
  final bool isAvailable;
  final double? avgRating;
  final int? reviewCount;
  final int? activeBookings;
  final double distanceKm;
  final int score;
  final bool willReachWithBuffer;

  const ChargerRecommendationEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.pricePerKwh,
    required this.chargerType,
    required this.isAvailable,
    this.avgRating,
    this.reviewCount,
    this.activeBookings,
    required this.distanceKm,
    required this.score,
    required this.willReachWithBuffer,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    location,
    latitude,
    longitude,
    pricePerKwh,
    chargerType,
    isAvailable,
    avgRating,
    reviewCount,
    activeBookings,
    distanceKm,
    score,
    willReachWithBuffer,
  ];
}

/// AI Demand-Based Pricing Entity
class DemandPricingEntity extends Equatable {
  final double currentPrice;
  final double predictedPrice;
  final double demandMultiplier;
  final String demandLevel;
  final int hour;
  final int dayOfWeek;
  final int forecastedOccupancy;

  const DemandPricingEntity({
    required this.currentPrice,
    required this.predictedPrice,
    required this.demandMultiplier,
    required this.demandLevel,
    required this.hour,
    required this.dayOfWeek,
    required this.forecastedOccupancy,
  });

  @override
  List<Object?> get props => [
    currentPrice,
    predictedPrice,
    demandMultiplier,
    demandLevel,
    hour,
    dayOfWeek,
    forecastedOccupancy,
  ];
}

/// AI Route Optimization Entity
class OptimizedRouteEntity extends Equatable {
  final List<RouteStopEntity> optimizedRoute;
  final int totalTimeMinutes;
  final int waypoints;
  final String efficiency;

  const OptimizedRouteEntity({
    required this.optimizedRoute,
    required this.totalTimeMinutes,
    required this.waypoints,
    required this.efficiency,
  });

  @override
  List<Object?> get props => [
    optimizedRoute,
    totalTimeMinutes,
    waypoints,
    efficiency,
  ];
}

/// Route Stop Entity
class RouteStopEntity extends Equatable {
  final String type;
  final ChargerRecommendationEntity? charger;
  final int? chargingTimeMinutes;
  final int? arrivalBattery;

  const RouteStopEntity({
    required this.type,
    this.charger,
    this.chargingTimeMinutes,
    this.arrivalBattery,
  });

  @override
  List<Object?> get props => [
    type,
    charger,
    chargingTimeMinutes,
    arrivalBattery,
  ];
}

/// AI Recommendation Entity
class AIRecommendationEntity extends Equatable {
  final String type;
  final String message;
  final String priority;

  const AIRecommendationEntity({
    required this.type,
    required this.message,
    required this.priority,
  });

  @override
  List<Object?> get props => [type, message, priority];
}
