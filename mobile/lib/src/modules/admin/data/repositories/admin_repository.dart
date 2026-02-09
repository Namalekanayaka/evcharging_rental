import 'package:dartz/dartz.dart';
import '../../domain/entities/admin_entities.dart';
import '../datasources/admin_remote_data_source.dart';
import '../../../../../core/error/failures.dart';

abstract class AdminRepository {
  Future<Either<Failure, List<AdminUserEntity>>> getUsers(int limit, int offset,
      {Map<String, dynamic>? filters});
  Future<Either<Failure, AdminUserEntity>> toggleUserSuspension(
      int userId, bool suspend);
  Future<Either<Failure, List<AdminChargerEntity>>> getChargers(
      int limit, int offset,
      {Map<String, dynamic>? filters});
  Future<Either<Failure, AdminChargerEntity>> approveCharger(
      int chargerId, bool approved,
      {String? reason});
  Future<Either<Failure, List<RevenueAnalyticsEntity>>> getRevenueAnalytics(
      String startDate, String endDate);
  Future<Either<Failure, PlatformAnalyticsSummaryEntity>>
      getPlatformAnalytics();
  Future<Either<Failure, List<FraudCaseEntity>>> getFraudCases(
      int limit, int offset);
  Future<Either<Failure, FraudCaseEntity>> resolveFraudCase(
      int caseId, String resolution,
      {String? notes});
  Future<Either<Failure, PromotionEntity>> createPromotion(
      Map<String, dynamic> promotionData);
  Future<Either<Failure, List<PromotionEntity>>> getPromotions(
      int limit, int offset);
  Future<Either<Failure, List<TopChargerEntity>>> getTopChargers(int limit);
}

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdminUserEntity>>> getUsers(
    int limit,
    int offset, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final result =
          await remoteDataSource.getUsers(limit, offset, filters: filters);
      return Right(result.map(_mapAdminUserEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminUserEntity>> toggleUserSuspension(
      int userId, bool suspend) async {
    try {
      final result =
          await remoteDataSource.toggleUserSuspension(userId, suspend);
      return Right(_mapAdminUserEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AdminChargerEntity>>> getChargers(
    int limit,
    int offset, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      final result =
          await remoteDataSource.getChargers(limit, offset, filters: filters);
      return Right(result.map(_mapAdminChargerEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AdminChargerEntity>> approveCharger(
    int chargerId,
    bool approved, {
    String? reason,
  }) async {
    try {
      final result = await remoteDataSource.approveCharger(chargerId, approved,
          reason: reason);
      return Right(_mapAdminChargerEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RevenueAnalyticsEntity>>> getRevenueAnalytics(
    String startDate,
    String endDate,
  ) async {
    try {
      final result =
          await remoteDataSource.getRevenueAnalytics(startDate, endDate);
      return Right(result.map(_mapRevenueAnalyticsEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlatformAnalyticsSummaryEntity>>
      getPlatformAnalytics() async {
    try {
      final result = await remoteDataSource.getPlatformAnalytics();
      return Right(_mapPlatformAnalyticsSummaryEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FraudCaseEntity>>> getFraudCases(
      int limit, int offset) async {
    try {
      final result = await remoteDataSource.getFraudCases(limit, offset);
      return Right(result.map(_mapFraudCaseEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, FraudCaseEntity>> resolveFraudCase(
    int caseId,
    String resolution, {
    String? notes,
  }) async {
    try {
      final result = await remoteDataSource.resolveFraudCase(caseId, resolution,
          notes: notes);
      return Right(_mapFraudCaseEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PromotionEntity>> createPromotion(
      Map<String, dynamic> promotionData) async {
    try {
      final result = await remoteDataSource.createPromotion(promotionData);
      return Right(_mapPromotionEntity(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PromotionEntity>>> getPromotions(
      int limit, int offset) async {
    try {
      final result = await remoteDataSource.getPromotions(limit, offset);
      return Right(result.map(_mapPromotionEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopChargerEntity>>> getTopChargers(
      int limit) async {
    try {
      final result = await remoteDataSource.getTopChargers(limit);
      return Right(result.map(_mapTopChargerEntity).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // Mapping functions
  AdminUserEntity _mapAdminUserEntity(Map<String, dynamic> json) {
    return AdminUserEntity(
      id: (json['id'] as num).toInt(),
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String? ?? '',
      email: json['email'] as String,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
      totalSpent: json['total_spent'] != null
          ? (json['total_spent'] as num).toDouble()
          : null,
    );
  }

  AdminChargerEntity _mapAdminChargerEntity(Map<String, dynamic> json) {
    return AdminChargerEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      location: json['location'] as String,
      chargerType: json['charger_type'] as String,
      pricePerKwh: (json['price_per_kwh'] as num).toDouble(),
      isActive: json['is_active'] as bool,
      isApproved: json['is_approved'] as bool,
      ownerId: (json['owner_id'] as num).toInt(),
      ownerName: json['owner_name'] as String? ?? 'Unknown',
      ownerEmail: json['owner_email'] as String? ?? 'N/A',
      avgRating: json['avg_rating'] != null
          ? (json['avg_rating'] as num).toDouble()
          : null,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      totalBookings: (json['total_bookings'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  RevenueAnalyticsEntity _mapRevenueAnalyticsEntity(Map<String, dynamic> json) {
    return RevenueAnalyticsEntity(
      date: DateTime.parse(json['date'] as String),
      transactionCount: (json['transaction_count'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgTransaction: (json['avg_transaction'] as num).toDouble(),
      userPayments: (json['user_payments'] as num).toDouble(),
      commissionEarned: (json['commission_earned'] as num).toDouble(),
    );
  }

  PlatformAnalyticsSummaryEntity _mapPlatformAnalyticsSummaryEntity(
      Map<String, dynamic> json) {
    return PlatformAnalyticsSummaryEntity(
      totalUsers: (json['total_users'] as num).toInt(),
      totalChargers: (json['total_chargers'] as num).toInt(),
      totalBookings: (json['total_bookings'] as num).toInt(),
      totalRevenue: (json['total_revenue'] as num).toDouble(),
      avgChargerRating: json['avg_charger_rating'] != null
          ? (json['avg_charger_rating'] as num).toDouble()
          : null,
      inactiveChargers: (json['inactive_chargers'] as num).toInt(),
    );
  }

  FraudCaseEntity _mapFraudCaseEntity(Map<String, dynamic> json) {
    return FraudCaseEntity(
      id: (json['id'] as num).toInt(),
      reporterId: (json['reporter_id'] as num).toInt(),
      respondentId: json['respondent_id'] != null
          ? (json['respondent_id'] as num).toInt()
          : null,
      disputeType: json['dispute_type'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      reporterName: json['reporter_name'] as String? ?? 'Anonymous',
      reporterEmail: json['reporter_email'] as String? ?? 'N/A',
      respondentName: json['respondent_name'] as String?,
      respondentEmail: json['respondent_email'] as String?,
    );
  }

  PromotionEntity _mapPromotionEntity(Map<String, dynamic> json) {
    return PromotionEntity(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      discountPercentage: (json['discount_percentage'] as num).toDouble(),
      code: json['code'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      maxUses: json['max_uses'] as int?,
      timesUsed: (json['times_used'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  TopChargerEntity _mapTopChargerEntity(Map<String, dynamic> json) {
    return TopChargerEntity(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      location: json['location'] as String,
      chargerType: json['charger_type'] as String,
      bookingCount: (json['booking_count'] as num).toInt(),
      avgRating: json['avg_rating'] != null
          ? (json['avg_rating'] as num).toDouble()
          : null,
      revenueGenerated: json['revenue_generated'] != null
          ? (json['revenue_generated'] as num).toDouble()
          : null,
    );
  }
}
