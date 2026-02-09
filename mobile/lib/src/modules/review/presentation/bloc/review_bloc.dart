import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/review_repository.dart';
import '../../domain/entities/review_entities.dart';

// ==================== EVENTS ====================

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class SubmitReviewEvent extends ReviewEvent {
  final int chargerId;
  final double rating;
  final String title;
  final String reviewText;
  final double? cleanliness;
  final double? safety;
  final double? supportRating;

  const SubmitReviewEvent(
    this.chargerId,
    this.rating,
    this.title,
    this.reviewText, {
    this.cleanliness,
    this.safety,
    this.supportRating,
  });

  @override
  List<Object?> get props =>
      [chargerId, rating, title, reviewText, cleanliness, safety, supportRating];
}

class GetChargerReviewsEvent extends ReviewEvent {
  final int chargerId;
  final int limit;
  final int offset;

  const GetChargerReviewsEvent(this.chargerId, {this.limit = 10, this.offset = 0});
  @override
  List<Object?> get props => [chargerId, limit, offset];
}

class GetUserReviewsEvent extends ReviewEvent {
  final int limit;
  final int offset;

  const GetUserReviewsEvent({this.limit = 20, this.offset = 0});
  @override
  List<Object?> get props => [limit, offset];
}

class GetUserTrustScoreEvent extends ReviewEvent {
  const GetUserTrustScoreEvent();
}

class MarkReviewHelpfulEvent extends ReviewEvent {
  final int reviewId;
  const MarkReviewHelpfulEvent(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}

class MarkReviewUnhelpfulEvent extends ReviewEvent {
  final int reviewId;
  const MarkReviewUnhelpfulEvent(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}

class GetPendingReviewsEvent extends ReviewEvent {
  final int limit;
  final int offset;

  const GetPendingReviewsEvent({this.limit = 20, this.offset = 0});
  @override
  List<Object?> get props => [limit, offset];
}

class ModerateReviewEvent extends ReviewEvent {
  final int reviewId;
  final bool approved;
  final String? reason;

  const ModerateReviewEvent(this.reviewId, this.approved, {this.reason});
  @override
  List<Object?> get props => [reviewId, approved, reason];
}

class DeleteReviewEvent extends ReviewEvent {
  final int reviewId;
  const DeleteReviewEvent(this.reviewId);
  @override
  List<Object?> get props => [reviewId];
}

class GetReviewStatisticsEvent extends ReviewEvent {
  final int chargerId;
  const GetReviewStatisticsEvent(this.chargerId);
  @override
  List<Object?> get props => [chargerId];
}

class GetOwnerRatingEvent extends ReviewEvent {
  const GetOwnerRatingEvent();
}

class ClearReviewEvent extends ReviewEvent {
  const ClearReviewEvent();
}

// ==================== STATES ====================

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitialState extends ReviewState {
  const ReviewInitialState();
}

class ReviewLoadingState extends ReviewState {
  const ReviewLoadingState();
}

class ReviewSubmittedState extends ReviewState {
  final ChargerReviewEntity review;
  const ReviewSubmittedState(this.review);
  @override
  List<Object?> get props => [review];
}

class ChargerReviewsSuccessState extends ReviewState {
  final List<ChargerReviewEntity> reviews;
  final int total;
  const ChargerReviewsSuccessState(this.reviews, this.total);
  @override
  List<Object?> get props => [reviews, total];
}

class UserReviewsSuccessState extends ReviewState {
  final List<ChargerReviewEntity> reviews;
  const UserReviewsSuccessState(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class TrustScoreSuccessState extends ReviewState {
  final TrustScoreEntity trustScore;
  const TrustScoreSuccessState(this.trustScore);
  @override
  List<Object?> get props => [trustScore];
}

class ReviewHelpfulMarkedState extends ReviewState {
  const ReviewHelpfulMarkedState();
}

class ReviewUnhelpfulMarkedState extends ReviewState {
  const ReviewUnhelpfulMarkedState();
}

class PendingReviewsSuccessState extends ReviewState {
  final List<PendingReviewEntity> reviews;
  const PendingReviewsSuccessState(this.reviews);
  @override
  List<Object?> get props => [reviews];
}

class ReviewModeratedState extends ReviewState {
  const ReviewModeratedState();
}

class ReviewDeletedState extends ReviewState {
  const ReviewDeletedState();
}

class ReviewStatisticsSuccessState extends ReviewState {
  final ReviewStatisticsEntity statistics;
  const ReviewStatisticsSuccessState(this.statistics);
  @override
  List<Object?> get props => [statistics];
}

class OwnerRatingSuccessState extends ReviewState {
  final OwnerRatingEntity rating;
  const OwnerRatingSuccessState(this.rating);
  @override
  List<Object?> get props => [rating];
}

class ReviewErrorState extends ReviewState {
  final String message;
  const ReviewErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository repository;

  ReviewBloc({required this.repository}) : super(const ReviewInitialState()) {
    on<SubmitReviewEvent>(_onSubmitReview);
    on<GetChargerReviewsEvent>(_onGetChargerReviews);
    on<GetUserReviewsEvent>(_onGetUserReviews);
    on<GetUserTrustScoreEvent>(_onGetUserTrustScore);
    on<MarkReviewHelpfulEvent>(_onMarkReviewHelpful);
    on<MarkReviewUnhelpfulEvent>(_onMarkReviewUnhelpful);
    on<GetPendingReviewsEvent>(_onGetPendingReviews);
    on<ModerateReviewEvent>(_onModerateReview);
    on<DeleteReviewEvent>(_onDeleteReview);
    on<GetReviewStatisticsEvent>(_onGetReviewStatistics);
    on<GetOwnerRatingEvent>(_onGetOwnerRating);
    on<ClearReviewEvent>(_onClearReview);
  }

  Future<void> _onSubmitReview(SubmitReviewEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.submitReview(
      event.chargerId,
      event.rating,
      event.title,
      event.reviewText,
      cleanliness: event.cleanliness,
      safety: event.safety,
      supportRating: event.supportRating,
    );
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (review) => emit(ReviewSubmittedState(review)),
    );
  }

  Future<void> _onGetChargerReviews(GetChargerReviewsEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.getChargerReviews(event.chargerId, event.limit, event.offset);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (data) {
        final reviews = (data['reviews'] as List?)?.cast<ChargerReviewEntity>() ?? [];
        final total = data['total'] as int? ?? 0;
        emit(ChargerReviewsSuccessState(reviews, total));
      },
    );
  }

  Future<void> _onGetUserReviews(GetUserReviewsEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.getUserReviews(event.limit, event.offset);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (reviews) => emit(UserReviewsSuccessState(reviews)),
    );
  }

  Future<void> _onGetUserTrustScore(GetUserTrustScoreEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.getUserTrustScore();
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (trustScore) => emit(TrustScoreSuccessState(trustScore)),
    );
  }

  Future<void> _onMarkReviewHelpful(MarkReviewHelpfulEvent event, Emitter<ReviewState> emit) async {
    final result = await repository.markReviewHelpful(event.reviewId);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (review) => emit(const ReviewHelpfulMarkedState()),
    );
  }

  Future<void> _onMarkReviewUnhelpful(MarkReviewUnhelpfulEvent event, Emitter<ReviewState> emit) async {
    final result = await repository.markReviewUnhelpful(event.reviewId);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (review) => emit(const ReviewUnhelpfulMarkedState()),
    );
  }

  Future<void> _onGetPendingReviews(GetPendingReviewsEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.getPendingReviews(event.limit, event.offset);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (reviews) => emit(PendingReviewsSuccessState(reviews)),
    );
  }

  Future<void> _onModerateReview(ModerateReviewEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.moderateReview(event.reviewId, event.approved, event.reason);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (review) => emit(const ReviewModeratedState()),
    );
  }

  Future<void> _onDeleteReview(DeleteReviewEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.deleteReview(event.reviewId);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (_) => emit(const ReviewDeletedState()),
    );
  }

  Future<void> _onGetReviewStatistics(GetReviewStatisticsEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.getReviewStatistics(event.chargerId);
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (statistics) => emit(ReviewStatisticsSuccessState(statistics)),
    );
  }

  Future<void> _onGetOwnerRating(GetOwnerRatingEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewLoadingState());
    final result = await repository.getOwnerRating();
    result.fold(
      (failure) => emit(ReviewErrorState(failure.message)),
      (rating) => emit(OwnerRatingSuccessState(rating)),
    );
  }

  Future<void> _onClearReview(ClearReviewEvent event, Emitter<ReviewState> emit) async {
    emit(const ReviewInitialState());
  }
}
