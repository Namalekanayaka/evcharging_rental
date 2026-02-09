import 'package:equatable/equatable.dart';

/// Charger Review Entity
class ChargerReviewEntity extends Equatable {
  final int id;
  final int chargerId;
  final int userId;
  final double rating; // 1-5
  final String title;
  final String reviewText;
  final double? cleanliness;
  final double? safety;
  final double? supportRating;
  final int isHelpfulCount;
  final int isUnhelpfulCount;
  final bool isApproved;
  final String? moderationReason;
  final DateTime createdAt;
  final DateTime? moderatedAt;

  // User details
  final String? firstName;
  final String? lastName;
  final String? profilePicture;

  const ChargerReviewEntity({
    required this.id,
    required this.chargerId,
    required this.userId,
    required this.rating,
    required this.title,
    required this.reviewText,
    this.cleanliness,
    this.safety,
    this.supportRating,
    this.isHelpfulCount = 0,
    this.isUnhelpfulCount = 0,
    required this.isApproved,
    this.moderationReason,
    required this.createdAt,
    this.moderatedAt,
    this.firstName,
    this.lastName,
    this.profilePicture,
  });

  String get userFullName =>
      '${firstName ?? 'Anonymous'} ${lastName ?? ''}'.trim();

  @override
  List<Object?> get props => [
        id,
        chargerId,
        userId,
        rating,
        title,
        reviewText,
        cleanliness,
        safety,
        supportRating,
        isHelpfulCount,
        isUnhelpfulCount,
        isApproved,
        moderationReason,
        createdAt,
        moderatedAt,
        firstName,
        lastName,
        profilePicture,
      ];
}

/// User Trust Score Entity
class TrustScoreEntity extends Equatable {
  final double trustScore; // 0-100
  final int totalReviews;
  final int rejectedReviews;
  final double helpfulnessRating; // 0-100

  const TrustScoreEntity({
    required this.trustScore,
    required this.totalReviews,
    required this.rejectedReviews,
    required this.helpfulnessRating,
  });

  String get trustLevel {
    if (trustScore >= 80) return 'Excellent';
    if (trustScore >= 60) return 'Good';
    if (trustScore >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  List<Object?> get props =>
      [trustScore, totalReviews, rejectedReviews, helpfulnessRating];
}

/// Review Statistics Entity
class ReviewStatisticsEntity extends Equatable {
  final int totalReviews;
  final double averageRating;
  final double averageCleanliness;
  final double averageSafety;
  final double averageSupport;
  final int positiveReviews;
  final int neutralReviews;
  final int negativeReviews;
  final int uniqueReviewers;

  const ReviewStatisticsEntity({
    required this.totalReviews,
    required this.averageRating,
    required this.averageCleanliness,
    required this.averageSafety,
    required this.averageSupport,
    required this.positiveReviews,
    required this.neutralReviews,
    required this.negativeReviews,
    required this.uniqueReviewers,
  });

  @override
  List<Object?> get props => [
        totalReviews,
        averageRating,
        averageCleanliness,
        averageSafety,
        averageSupport,
        positiveReviews,
        neutralReviews,
        negativeReviews,
        uniqueReviewers,
      ];
}

/// Owner Rating Entity
class OwnerRatingEntity extends Equatable {
  final double avgRating;
  final int chargerCount;
  final int totalReviews;

  const OwnerRatingEntity({
    required this.avgRating,
    required this.chargerCount,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [avgRating, chargerCount, totalReviews];
}

/// Pending Review (for moderation)
class PendingReviewEntity extends Equatable {
  final int id;
  final String chargerName;
  final String firstName;
  final String lastName;
  final double rating;
  final String title;
  final String reviewText;
  final DateTime createdAt;

  const PendingReviewEntity({
    required this.id,
    required this.chargerName,
    required this.firstName,
    required this.lastName,
    required this.rating,
    required this.title,
    required this.reviewText,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        chargerName,
        firstName,
        lastName,
        rating,
        title,
        reviewText,
        createdAt,
      ];
}
