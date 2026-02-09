import 'package:equatable/equatable.dart';

/// Admin User Management Entity
class AdminUserEntity extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalBookings;
  final double? totalSpent;

  const AdminUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.totalBookings,
    this.totalSpent,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        isActive,
        createdAt,
        updatedAt,
        totalBookings,
        totalSpent,
      ];
}

/// Admin Charger Management Entity
class AdminChargerEntity extends Equatable {
  final int id;
  final String name;
  final String location;
  final String chargerType;
  final double pricePerKwh;
  final bool isActive;
  final bool isApproved;
  final int ownerId;
  final String ownerName;
  final String ownerEmail;
  final double? avgRating;
  final int reviewCount;
  final int totalBookings;
  final DateTime createdAt;

  const AdminChargerEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.chargerType,
    required this.pricePerKwh,
    required this.isActive,
    required this.isApproved,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    this.avgRating,
    required this.reviewCount,
    required this.totalBookings,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        chargerType,
        pricePerKwh,
        isActive,
        isApproved,
        ownerId,
        ownerName,
        ownerEmail,
        avgRating,
        reviewCount,
        totalBookings,
        createdAt,
      ];
}

/// Revenue Analytics Entity
class RevenueAnalyticsEntity extends Equatable {
  final DateTime date;
  final int transactionCount;
  final double totalRevenue;
  final double avgTransaction;
  final double userPayments;
  final double commissionEarned;

  const RevenueAnalyticsEntity({
    required this.date,
    required this.transactionCount,
    required this.totalRevenue,
    required this.avgTransaction,
    required this.userPayments,
    required this.commissionEarned,
  });

  @override
  List<Object?> get props => [
        date,
        transactionCount,
        totalRevenue,
        avgTransaction,
        userPayments,
        commissionEarned,
      ];
}

/// Platform Analytics Summary Entity
class PlatformAnalyticsSummaryEntity extends Equatable {
  final int totalUsers;
  final int totalChargers;
  final int totalBookings;
  final double totalRevenue;
  final double? avgChargerRating;
  final int inactiveChargers;

  const PlatformAnalyticsSummaryEntity({
    required this.totalUsers,
    required this.totalChargers,
    required this.totalBookings,
    required this.totalRevenue,
    this.avgChargerRating,
    required this.inactiveChargers,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        totalChargers,
        totalBookings,
        totalRevenue,
        avgChargerRating,
        inactiveChargers,
      ];
}

/// Fraud Case Entity
class FraudCaseEntity extends Equatable {
  final int id;
  final int reporterId;
  final int? respondentId;
  final String disputeType;
  final String status;
  final double amount;
  final DateTime createdAt;
  final String reporterName;
  final String reporterEmail;
  final String? respondentName;
  final String? respondentEmail;

  const FraudCaseEntity({
    required this.id,
    required this.reporterId,
    this.respondentId,
    required this.disputeType,
    required this.status,
    required this.amount,
    required this.createdAt,
    required this.reporterName,
    required this.reporterEmail,
    this.respondentName,
    this.respondentEmail,
  });

  @override
  List<Object?> get props => [
        id,
        reporterId,
        respondentId,
        disputeType,
        status,
        amount,
        createdAt,
        reporterName,
        reporterEmail,
        respondentName,
        respondentEmail,
      ];
}

/// Promotion Entity
class PromotionEntity extends Equatable {
  final int id;
  final String title;
  final String description;
  final double discountPercentage;
  final String code;
  final DateTime startDate;
  final DateTime endDate;
  final int? maxUses;
  final int timesUsed;
  final bool isActive;
  final DateTime createdAt;

  const PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.code,
    required this.startDate,
    required this.endDate,
    this.maxUses,
    required this.timesUsed,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        discountPercentage,
        code,
        startDate,
        endDate,
        maxUses,
        timesUsed,
        isActive,
        createdAt,
      ];
}

/// Top Charger Analytics Entity
class TopChargerEntity extends Equatable {
  final int id;
  final String name;
  final String location;
  final String chargerType;
  final int bookingCount;
  final double? avgRating;
  final double? revenueGenerated;

  const TopChargerEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.chargerType,
    required this.bookingCount,
    this.avgRating,
    this.revenueGenerated,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        location,
        chargerType,
        bookingCount,
        avgRating,
        revenueGenerated,
      ];
}
