import 'package:equatable/equatable.dart';

/// Pricing Package Entity
class PricingPackageEntity extends Equatable {
  final int id;
  final String name;
  final String tier; // 'basic', 'pro', 'premium'
  final double monthlyPrice;
  final double annualPrice;
  final List<String> features;
  final double commissionRate; // Percentage taken by platform
  final bool isActive;
  final DateTime createdAt;

  const PricingPackageEntity({
    required this.id,
    required this.name,
    required this.tier,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.features,
    required this.commissionRate,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    tier,
    monthlyPrice,
    annualPrice,
    features,
    commissionRate,
    isActive,
    createdAt,
  ];
}

/// User Subscription Entity
class SubscriptionEntity extends Equatable {
  final int id;
  final int userId;
  final int packageId;
  final String billingCycle; // 'monthly' or 'annual'
  final double amount;
  final DateTime nextBillingDate;
  final DateTime? cancelledAt;
  final bool isActive;
  final DateTime createdAt;
  
  // Package details
  final String packageName;
  final String tier;
  final List<String>? features;
  final double? commissionRate;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.packageId,
    required this.billingCycle,
    required this.amount,
    required this.nextBillingDate,
    this.cancelledAt,
    required this.isActive,
    required this.createdAt,
    required this.packageName,
    required this.tier,
    this.features,
    this.commissionRate,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    packageId,
    billingCycle,
    amount,
    nextBillingDate,
    cancelledAt,
    isActive,
    createdAt,
    packageName,
    tier,
    features,
    commissionRate,
  ];
}

/// Dynamic Pricing Entity
class DynamicPricingEntity extends Equatable {
  final double basePrice;
  final String demandLevel; // low, medium, high, peak
  final double demandMultiplier;
  final double dynamicPrice;

  const DynamicPricingEntity({
    required this.basePrice,
    required this.demandLevel,
    required this.demandMultiplier,
    required this.dynamicPrice,
  });

  @override
  List<Object?> get props => [basePrice, demandLevel, demandMultiplier, dynamicPrice];
}

/// Pricing History Entity
class PricingHistoryEntity extends Equatable {
  final DateTime date;
  final double avgPrice;
  final double maxPrice;
  final double minPrice;
  final int bookingsCount;

  const PricingHistoryEntity({
    required this.date,
    required this.avgPrice,
    required this.maxPrice,
    required this.minPrice,
    required this.bookingsCount,
  });

  @override
  List<Object?> get props => [date, avgPrice, maxPrice, minPrice, bookingsCount];
}

/// Commission Breakdown Entity
class CommissionBreakdownEntity extends Equatable {
  final int chargerId;
  final String chargerName;
  final double totalRevenue;
  final double commissionRate;
  final double platformCommission;
  final double ownerEarnings;
  final int bookingsCount;

  const CommissionBreakdownEntity({
    required this.chargerId,
    required this.chargerName,
    required this.totalRevenue,
    required this.commissionRate,
    required this.platformCommission,
    required this.ownerEarnings,
    required this.bookingsCount,
  });

  @override
  List<Object?> get props => [
    chargerId,
    chargerName,
    totalRevenue,
    commissionRate,
    platformCommission,
    ownerEarnings,
    bookingsCount,
  ];
}

/// Pricing Rule Entity
class PricingRuleEntity extends Equatable {
  final int id;
  final int chargerId;
  final String ruleName;
  final Map<String, dynamic> conditions;
  final double priceModifier;
  final bool isActive;
  final DateTime createdAt;

  const PricingRuleEntity({
    required this.id,
    required this.chargerId,
    required this.ruleName,
    required this.conditions,
    required this.priceModifier,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    chargerId,
    ruleName,
    conditions,
    priceModifier,
    isActive,
    createdAt,
  ];
}

/// Subscription Analytics Entity
class SubscriptionAnalyticsEntity extends Equatable {
  final String packageName;
  final String tier;
  final int subscriberCount;
  final double totalRevenue;
  final double avgSubscriptionValue;

  const SubscriptionAnalyticsEntity({
    required this.packageName,
    required this.tier,
    required this.subscriberCount,
    required this.totalRevenue,
    required this.avgSubscriptionValue,
  });

  @override
  List<Object?> get props => [
    packageName,
    tier,
    subscriberCount,
    totalRevenue,
    avgSubscriptionValue,
  ];
}
