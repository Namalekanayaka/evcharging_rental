import 'package:dartz/dartz.dart';
import '../datasources/search_remote_data_source.dart';
import '../entities/search_entities.dart';
import '../../../../../core/error/failures.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<ChargerSearchResultEntity>>> searchNearbyChargers(
    SearchFilterEntity filters,
  );
  Future<Either<Failure, ChargerSearchResultEntity?>> getRecommendedCharger(
    double latitude,
    double longitude, {
    int? batteryPercentage,
    bool urgentCharging,
  });
  Future<Either<Failure, List<ChargerSearchResultEntity>>> searchByLocation(
    String query, {
    int limit,
    int offset,
  });
  Future<Either<Failure, AvailabilityEntity>> getChargerAvailability(
    int chargerId,
  );
  Future<Either<Failure, List<ChargerSearchResultEntity>>> getChargersInArea(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  );
  Future<Either<Failure, RouteInfoEntity>> calculateRoute(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  );
  Future<Either<Failure, Map<String, dynamic>>> advancedSearch(
    Map<String, dynamic> searchCriteria,
  );
  Future<Either<Failure, List<ChargerSearchResultEntity>>> getTrendingChargers({
    int limit,
    int radiusKm,
  });
}

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;

  SearchRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> searchNearbyChargers(
    SearchFilterEntity filters,
  ) async {
    try {
      final chargers = await remoteDataSource.searchNearbyChargers(filters);
      return Right(chargers);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChargerSearchResultEntity?>> getRecommendedCharger(
    double latitude,
    double longitude, {
    int? batteryPercentage,
    bool urgentCharging = false,
  }) async {
    try {
      final charger = await remoteDataSource.getRecommendedCharger(
        latitude,
        longitude,
        batteryPercentage: batteryPercentage,
        urgentCharging: urgentCharging,
      );
      return Right(charger);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> searchByLocation(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      if (query.isEmpty) {
        return Left(ValidationFailure(message: 'Search query cannot be empty'));
      }

      final chargers = await remoteDataSource.searchByLocation(query,
          limit: limit, offset: offset);
      return Right(chargers);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AvailabilityEntity>> getChargerAvailability(
    int chargerId,
  ) async {
    try {
      final availability =
          await remoteDataSource.getChargerAvailability(chargerId);
      return Right(availability);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> getChargersInArea(
    double minLat,
    double maxLat,
    double minLng,
    double maxLng,
  ) async {
    try {
      final chargers = await remoteDataSource.getChargersInArea(
          minLat, maxLat, minLng, maxLng);
      return Right(chargers);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, RouteInfoEntity>> calculateRoute(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    try {
      final route =
          await remoteDataSource.calculateRoute(fromLat, fromLng, toLat, toLng);
      return Right(route);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> advancedSearch(
    Map<String, dynamic> searchCriteria,
  ) async {
    try {
      final results = await remoteDataSource.advancedSearch(searchCriteria);
      return Right(results);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChargerSearchResultEntity>>> getTrendingChargers({
    int limit = 10,
    int radiusKm = 50,
  }) async {
    try {
      final chargers = await remoteDataSource.getTrendingChargers(
        limit: limit,
        radiusKm: radiusKm,
      );
      return Right(chargers);
    } on Exception catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
