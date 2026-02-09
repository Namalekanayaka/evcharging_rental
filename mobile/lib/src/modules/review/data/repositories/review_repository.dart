import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../domain/entities/review_entities.dart';
import '../datasources/review_remote_data_source.dart';

abstract class ReviewRepository {
  Future<Either<Failure, ChargerReviewEntity>> submitReview(
    int chargerId,
    double rating,
    String title,
    String reviewText, {
    double? cleanliness,
    double? safety,
    double? supportRating,
  });
  Future<Either<Failure, Map<String, dynamic>>> getChargerReviews(int chargerId, int limit, int offset);
  Future<Either<Failure, List<ChargerReviewEntity>>> getUserReviews(int limit, int offset);
  Future<Either<Failure, TrustScoreEntity>> getUserTrustScore();
  Future<Either<Failure, ChargerReviewEntity>> markReviewHelpful(int reviewId);
  Future<Either<Failure, ChargerReviewEntity>> markReviewUnhelpful(int reviewId);
  Future<Either<Failure, List<PendingReviewEntity>>> getPendingReviews(int limit, int offset);
  Future<Either<Failure, ChargerReviewEntity>> moderateReview(int reviewId, bool approved, String? reason);
  Future<Either<Failure, void>> deleteReview(int reviewId);
  Future<Either<Failure, ReviewStatisticsEntity>> getReviewStatistics(int chargerId);
  Future<Either<Failure, OwnerRatingEntity>> getOwnerRating();
}

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;

  ReviewRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ChargerReviewEntity>> submitReview(
    int chargerId,
    double rating,
    String title,
    String reviewText, {
    double? cleanliness,
    double? safety,
    double? supportRating,
  }) async {
    try {
      final result = await remoteDataSource.submitReview(
        chargerId,
        rating,
        title,
        reviewText,
        cleanliness: cleanliness,
        safety: safety,
        supportRating: supportRating,
      );
      return Right(_mapToChargerReview(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getChargerReviews(int chargerId, int limit, int offset) async {
    try {
      final result = await remoteDataSource.getChargerReviews(chargerId, limit, offset);
      final reviews = (result['reviews'] as List?)?.map((r) => _mapToChargerReview(r as Map<String, dynamic>)).toList() ?? [];
      final total = result['total'] ?? 0;
      return Right({
        'reviews': reviews,
        'total': total,
      });
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ChargerReviewEntity>>> getUserReviews(int limit, int offset) async {
    try {
      final result = await remoteDataSource.getUserReviews(limit, offset);
      final reviews = (result as List).map((r) => _mapToChargerReview(r as Map<String, dynamic>)).toList();
      return Right(reviews);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TrustScoreEntity>> getUserTrustScore() async {
    try {
      final result = await remoteDataSource.getUserTrustScore();
      return Right(_mapToTrustScore(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChargerReviewEntity>> markReviewHelpful(int reviewId) async {
    try {
      final result = await remoteDataSource.markReviewHelpful(reviewId);
      return Right(_mapToChargerReview(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChargerReviewEntity>> markReviewUnhelpful(int reviewId) async {
    try {
      final result = await remoteDataSource.markReviewUnhelpful(reviewId);
      return Right(_mapToChargerReview(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PendingReviewEntity>>> getPendingReviews(int limit, int offset) async {
    try {
      final result = await remoteDataSource.getPendingReviews(limit, offset);
      final reviews = (result as List).map((r) => _mapToPendingReview(r as Map<String, dynamic>)).toList();
      return Right(reviews);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ChargerReviewEntity>> moderateReview(int reviewId, bool approved, String? reason) async {
    try {
      final result = await remoteDataSource.moderateReview(reviewId, approved, reason);
      return Right(_mapToChargerReview(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(int reviewId) async {
    try {
      await remoteDataSource.deleteReview(reviewId);
      return const Right(null);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewStatisticsEntity>> getReviewStatistics(int chargerId) async {
    try {
      final result = await remoteDataSource.getReviewStatistics(chargerId);
      return Right(_mapToReviewStatistics(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, OwnerRatingEntity>> getOwnerRating() async {
    try {
      final result = await remoteDataSource.getOwnerRating();
      return Right(_mapToOwnerRating(result));
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  // Mapping functions
  ChargerReviewEntity _mapToChargerReview(Map<String, dynamic> data) {
    return ChargerReviewEntity(
      id: data['id'] ?? 0,
      chargerId: data['charger_id'] ?? 0,
      userId: data['user_id'] ?? 0,
      rating: (data['rating'] ?? 0).toDouble(),
      title: data['title'] ?? '',
      reviewText: data['review_text'] ?? '',
      cleanliness: data['cleanliness'] != null ? (data['cleanliness']).toDouble() : null,
      safety: data['safety'] != null ? (data['safety']).toDouble() : null,
      supportRating: data['support_rating'] != null ? (data['support_rating']).toDouble() : null,
      isHelpfulCount: data['is_helpful_count'] ?? 0,
      isUnhelpfulCount: data['is_unhelpful_count'] ?? 0,
      isApproved: data['is_approved'] ?? false,
      moderationReason: data['moderation_reason'],
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toString()),
      moderatedAt: data['moderated_at'] != null ? DateTime.parse(data['moderated_at']) : null,
      firstName: data['first_name'],
      lastName: data['last_name'],
      profilePicture: data['profile_picture'],
    );
  }

  TrustScoreEntity _mapToTrustScore(Map<String, dynamic> data) {
    return TrustScoreEntity(
      trustScore: (data['trustScore'] ?? 100).toDouble(),
      totalReviews: data['totalReviews'] ?? 0,
      rejectedReviews: data['rejectedReviews'] ?? 0,
      helpfulnessRating: (data['helpfulnessRating'] ?? 0).toDouble(),
    );
  }

  ReviewStatisticsEntity _mapToReviewStatistics(Map<String, dynamic> data) {
    return ReviewStatisticsEntity(
      totalReviews: data['total_reviews'] ?? 0,
      averageRating: (data['average_rating'] ?? 0).toDouble(),
      averageCleanliness: (data['average_cleanliness'] ?? 0).toDouble(),
      averageSafety: (data['average_safety'] ?? 0).toDouble(),
      averageSupport: (data['average_support'] ?? 0).toDouble(),
      positiveReviews: data['positive_reviews'] ?? 0,
      neutralReviews: data['neutral_reviews'] ?? 0,
      negativeReviews: data['negative_reviews'] ?? 0,
      uniqueReviewers: data['unique_reviewers'] ?? 0,
    );
  }

  OwnerRatingEntity _mapToOwnerRating(Map<String, dynamic> data) {
    return OwnerRatingEntity(
      avgRating: (data['avg_rating'] ?? 0).toDouble(),
      chargerCount: data['charger_count'] ?? 0,
      totalReviews: data['total_reviews'] ?? 0,
    );
  }

  PendingReviewEntity _mapToPendingReview(Map<String, dynamic> data) {
    return PendingReviewEntity(
      id: data['id'] ?? 0,
      chargerName: data['charger_name'] ?? '',
      firstName: data['first_name'] ?? '',
      lastName: data['last_name'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      title: data['title'] ?? '',
      reviewText: data['review_text'] ?? '',
      createdAt: DateTime.parse(data['created_at'] ?? DateTime.now().toString()),
    );
  }
}
