import 'package:dartz/dartz.dart';
import '../../data/entities/search_entities.dart';
import '../../data/repositories/search_repository.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';

class SearchNearbyChargersUseCase
    implements UseCase<List<ChargerSearchResultEntity>, SearchFilterEntity> {
  final SearchRepository repository;

  SearchNearbyChargersUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> call(
    SearchFilterEntity params,
  ) async {
    return await repository.searchNearbyChargers(params);
  }
}

class GetRecommendedChargerUseCase
    implements
        UseCase<ChargerSearchResultEntity?, GetRecommendedChargerParams> {
  final SearchRepository repository;

  GetRecommendedChargerUseCase({required this.repository});

  @override
  Future<Either<Failure, ChargerSearchResultEntity?>> call(
    GetRecommendedChargerParams params,
  ) async {
    return await repository.getRecommendedCharger(
      params.latitude,
      params.longitude,
      batteryPercentage: params.batteryPercentage,
      urgentCharging: params.urgentCharging,
    );
  }
}

class GetRecommendedChargerParams {
  final double latitude;
  final double longitude;
  final int? batteryPercentage;
  final bool urgentCharging;

  GetRecommendedChargerParams({
    required this.latitude,
    required this.longitude,
    this.batteryPercentage,
    this.urgentCharging = false,
  });
}

class SearchByLocationUseCase
    implements
        UseCase<List<ChargerSearchResultEntity>, SearchByLocationParams> {
  final SearchRepository repository;

  SearchByLocationUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> call(
    SearchByLocationParams params,
  ) async {
    return await repository.searchByLocation(
      params.query,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class SearchByLocationParams {
  final String query;
  final int limit;
  final int offset;

  SearchByLocationParams({
    required this.query,
    this.limit = 20,
    this.offset = 0,
  });
}

class GetChargerAvailabilityUseCase
    implements UseCase<AvailabilityEntity, int> {
  final SearchRepository repository;

  GetChargerAvailabilityUseCase({required this.repository});

  @override
  Future<Either<Failure, AvailabilityEntity>> call(int chargerId) async {
    return await repository.getChargerAvailability(chargerId);
  }
}

class GetChargersInAreaUseCase
    implements
        UseCase<List<ChargerSearchResultEntity>, GetChargersInAreaParams> {
  final SearchRepository repository;

  GetChargersInAreaUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> call(
    GetChargersInAreaParams params,
  ) async {
    return await repository.getChargersInArea(
      params.minLat,
      params.maxLat,
      params.minLng,
      params.maxLng,
    );
  }
}

class GetChargersInAreaParams {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  GetChargersInAreaParams({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });
}

class CalculateRouteUseCase
    implements UseCase<RouteInfoEntity, CalculateRouteParams> {
  final SearchRepository repository;

  CalculateRouteUseCase({required this.repository});

  @override
  Future<Either<Failure, RouteInfoEntity>> call(
    CalculateRouteParams params,
  ) async {
    return await repository.calculateRoute(
      params.fromLat,
      params.fromLng,
      params.toLat,
      params.toLng,
    );
  }
}

class CalculateRouteParams {
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;

  CalculateRouteParams({
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
  });
}

class AdvancedSearchUseCase
    implements UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final SearchRepository repository;

  AdvancedSearchUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    Map<String, dynamic> params,
  ) async {
    return await repository.advancedSearch(params);
  }
}

class GetTrendingChargersUseCase
    implements
        UseCase<List<ChargerSearchResultEntity>, GetTrendingChargersParams> {
  final SearchRepository repository;

  GetTrendingChargersUseCase({required this.repository});

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> call(
    GetTrendingChargersParams params,
  ) async {
    return await repository.getTrendingChargers(
      limit: params.limit,
      radiusKm: params.radiusKm,
    );
  }
}

class GetTrendingChargersParams {
  final int limit;
  final int radiusKm;

  GetTrendingChargersParams({
    this.limit = 10,
    this.radiusKm = 50,
  });
}
