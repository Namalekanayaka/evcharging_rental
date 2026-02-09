import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/pricing_entities.dart';
import '../datasources/pricing_remote_data_source.dart';

abstract class PricingRepository {
  Future<Either<Failure, List<PricingPackageEntity>>> getPricingPackages();
  Future<Either<Failure, SubscriptionEntity?>> getUserSubscription();
  Future<Either<Failure, SubscriptionEntity>> subscribeToPackage(int packageId, String billingCycle);
  Future<Either<Failure, SubscriptionEntity>> cancelSubscription();
  Future<Either<Failure, DynamicPricingEntity>> getDynamicPrice(int chargerId, String demandLevel);
  Future<Either<Failure, List<PricingHistoryEntity>>> getPricingHistory(int chargerId, int days);
  Future<Either<Failure, List<CommissionBreakdownEntity>>> getCommissionBreakdown(int? month, int? year);
}

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource remoteDataSource;

  PricingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PricingPackageEntity>>> getPricingPackages() async {
    try {
      final result = await remoteDataSource.getPricingPackages();
      final packages = result.map((p) => _mapToPricingPackage(p)).toList();
      return Right(packages);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity?>> getUserSubscription() async {
    try {
      final result = await remoteDataSource.getUserSubscription();
      if (result.isEmpty) return const Right(null);
      return Right(_mapToSubscription(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> subscribeToPackage(int packageId, String billingCycle) async {
    try {
      final result = await remoteDataSource.subscribeToPackage(packageId, billingCycle);
      return Right(_mapToSubscription(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionEntity>> cancelSubscription() async {
    try {
      final result = await remoteDataSource.cancelSubscription();
      return Right(_mapToSubscription(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DynamicPricingEntity>> getDynamicPrice(int chargerId, String demandLevel) async {
    try {
      final result = await remoteDataSource.getDynamicPrice(chargerId, demandLevel);
      return Right(_mapToDynamicPricing(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PricingHistoryEntity>>> getPricingHistory(int chargerId, int days) async {
    try {
      final result = await remoteDataSource.getPricingHistory(chargerId, days);
      final history = result.map((h) => _mapToPricingHistory(h)).toList();
      return Right(history);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CommissionBreakdownEntity>>> getCommissionBreakdown(int? month, int? year) async {
    try {
      final result = await remoteDataSource.getCommissionBreakdown(month, year);
      final breakdown = result.map((c) => _mapToCommissionBreakdown(c)).toList();
      return Right(breakdown);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // Mapping functions
  PricingPackageEntity _mapToPricingPackage(Map<String, dynamic> data) {
    return PricingPackageEntity(
      id: data['id'] ?? 0,
      name: data['name'] ?? '',
      tier: data['tier'] ?? '',
      monthlyPrice: (data['monthly_price'] ?? 0).toDouble(),
      annualPrice: (data['annual_price'] ?? 0).toDouble(),
      features: List<String>.from(data['features'] ?? []),
      commissionRate: (data['commission_rate'] ?? 0).toDouble(),
      isActive: data['is_active'] ?? false,
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toString()),
    );
  }

  SubscriptionEntity _mapToSubscription(Map<String, dynamic> data) {
    return SubscriptionEntity(
      id: data['id'] ?? 0,
      userId: data['user_id'] ?? 0,
      packageId: data['package_id'] ?? 0,
      billingCycle: data['billing_cycle'] ?? 'monthly',
      amount: (data['amount'] ?? 0).toDouble(),
      nextBillingDate: DateTime.parse(data['next_billing_date'] ?? DateTime.now().toString()),
      cancelledAt: data['cancelled_at'] != null ? DateTime.parse(data['cancelled_at']) : null,
      isActive: data['is_active'] ?? false,
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toString()),
      packageName: data['name'] ?? '',
      tier: data['tier'] ?? '',
      features: List<String>.from(data['features'] ?? []),
      commissionRate: (data['commission_rate'] ?? 0).toDouble(),
    );
  }

  DynamicPricingEntity _mapToDynamicPricing(Map<String, dynamic> data) {
    return DynamicPricingEntity(
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      demandLevel: data['demandLevel'] ?? 'medium',
      demandMultiplier: (data['demandMultiplier'] ?? 1.0).toDouble(),
      dynamicPrice: (data['dynamicPrice'] ?? 0).toDouble(),
    );
  }

  PricingHistoryEntity _mapToPricingHistory(Map<String, dynamic> data) {
    return PricingHistoryEntity(
      date: DateTime.parse(data['date'] ?? DateTime.now().toString()),
      avgPrice: (data['avg_price'] ?? 0).toDouble(),
      maxPrice: (data['max_price'] ?? 0).toDouble(),
      minPrice: (data['min_price'] ?? 0).toDouble(),
      bookingsCount: data['bookings_count'] ?? 0,
    );
  }

  CommissionBreakdownEntity _mapToCommissionBreakdown(Map<String, dynamic> data) {
    return CommissionBreakdownEntity(
      chargerId: data['charger_id'] ?? 0,
      chargerName: data['charger_name'] ?? '',
      totalRevenue: (data['total_revenue'] ?? 0).toDouble(),
      commissionRate: (data['commission_rate'] ?? 0).toDouble(),
      platformCommission: (data['platform_commission'] ?? 0).toDouble(),
      ownerEarnings: (data['owner_earnings'] ?? 0).toDouble(),
      bookingsCount: data['bookings_count'] ?? 0,
    );
  }
}
