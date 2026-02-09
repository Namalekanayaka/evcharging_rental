import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/pricing_repository.dart';
import '../../domain/entities/pricing_entities.dart';

// ==================== EVENTS ====================

abstract class PricingEvent extends Equatable {
  const PricingEvent();
  @override
  List<Object?> get props => [];
}

class GetPricingPackagesEvent extends PricingEvent {
  const GetPricingPackagesEvent();
}

class GetUserSubscriptionEvent extends PricingEvent {
  const GetUserSubscriptionEvent();
}

class SubscribeToPackageEvent extends PricingEvent {
  final int packageId;
  final String billingCycle;

  const SubscribeToPackageEvent(this.packageId, this.billingCycle);
  @override
  List<Object?> get props => [packageId, billingCycle];
}

class CancelSubscriptionEvent extends PricingEvent {
  const CancelSubscriptionEvent();
}

class GetDynamicPriceEvent extends PricingEvent {
  final int chargerId;
  final String demandLevel;

  const GetDynamicPriceEvent(this.chargerId, {this.demandLevel = 'medium'});
  @override
  List<Object?> get props => [chargerId, demandLevel];
}

class GetPricingHistoryEvent extends PricingEvent {
  final int chargerId;
  final int days;

  const GetPricingHistoryEvent(this.chargerId, {this.days = 30});
  @override
  List<Object?> get props => [chargerId, days];
}

class GetCommissionBreakdownEvent extends PricingEvent {
  final int? month;
  final int? year;

  const GetCommissionBreakdownEvent({this.month, this.year});
  @override
  List<Object?> get props => [month, year];
}

class ClearPricingEvent extends PricingEvent {
  const ClearPricingEvent();
}

// ==================== STATES ====================

abstract class PricingState extends Equatable {
  const PricingState();
  @override
  List<Object?> get props => [];
}

class PricingInitialState extends PricingState {
  const PricingInitialState();
}

class PricingLoadingState extends PricingState {
  const PricingLoadingState();
}

class PricingPackagesSuccessState extends PricingState {
  final List<PricingPackageEntity> packages;
  const PricingPackagesSuccessState(this.packages);
  @override
  List<Object?> get props => [packages];
}

class SubscriptionSuccessState extends PricingState {
  final SubscriptionEntity subscription;
  const SubscriptionSuccessState(this.subscription);
  @override
  List<Object?> get props => [subscription];
}

class SubscriptionCancelledState extends PricingState {
  const SubscriptionCancelledState();
}

class DynamicPricingSuccessState extends PricingState {
  final DynamicPricingEntity pricing;
  const DynamicPricingSuccessState(this.pricing);
  @override
  List<Object?> get props => [pricing];
}

class PricingHistorySuccessState extends PricingState {
  final List<PricingHistoryEntity> history;
  const PricingHistorySuccessState(this.history);
  @override
  List<Object?> get props => [history];
}

class CommissionBreakdownSuccessState extends PricingState {
  final List<CommissionBreakdownEntity> breakdown;
  const CommissionBreakdownSuccessState(this.breakdown);
  @override
  List<Object?> get props => [breakdown];
}

class PricingErrorState extends PricingState {
  final String message;
  const PricingErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class PricingBloc extends Bloc<PricingEvent, PricingState> {
  final PricingRepository repository;

  PricingBloc({required this.repository}) : super(const PricingInitialState()) {
    on<GetPricingPackagesEvent>(_onGetPricingPackages);
    on<GetUserSubscriptionEvent>(_onGetUserSubscription);
    on<SubscribeToPackageEvent>(_onSubscribeToPackage);
    on<CancelSubscriptionEvent>(_onCancelSubscription);
    on<GetDynamicPriceEvent>(_onGetDynamicPrice);
    on<GetPricingHistoryEvent>(_onGetPricingHistory);
    on<GetCommissionBreakdownEvent>(_onGetCommissionBreakdown);
    on<ClearPricingEvent>(_onClearPricing);
  }

  Future<void> _onGetPricingPackages(
      GetPricingPackagesEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result = await repository.getPricingPackages();
    result.fold(
      (failure) => emit(PricingErrorState(failure.message)),
      (packages) => emit(PricingPackagesSuccessState(packages)),
    );
  }

  Future<void> _onGetUserSubscription(
      GetUserSubscriptionEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result = await repository.getUserSubscription();
    result.fold(
      (failure) => emit(PricingErrorState(failure.message)),
      (subscription) {
        if (subscription != null) {
          emit(SubscriptionSuccessState(subscription));
        } else {
          emit(const PricingInitialState());
        }
      },
    );
  }

  Future<void> _onSubscribeToPackage(
      SubscribeToPackageEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result = await repository.subscribeToPackage(
        event.packageId, event.billingCycle);
    result.fold(
      (failure) => emit(PricingErrorState(failure.message)),
      (subscription) => emit(SubscriptionSuccessState(subscription)),
    );
  }

  Future<void> _onCancelSubscription(
      CancelSubscriptionEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result = await repository.cancelSubscription();
    result.fold(
      (failure) => emit(PricingErrorState(failure.message)),
      (subscription) => emit(const SubscriptionCancelledState()),
    );
  }

  Future<void> _onGetDynamicPrice(
      GetDynamicPriceEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result =
        await repository.getDynamicPrice(event.chargerId, event.demandLevel);
    result.fold(
      (failure) => emit(PricingErrorState(failure.message)),
      (pricing) => emit(DynamicPricingSuccessState(pricing)),
    );
  }

  Future<void> _onGetPricingHistory(
      GetPricingHistoryEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result =
        await repository.getPricingHistory(event.chargerId, event.days);
    result.fold(
      (failure) => emit(PricingErrorState(failure.message)),
      (history) => emit(PricingHistorySuccessState(history)),
    );
  }

  Future<void> _onGetCommissionBreakdown(
      GetCommissionBreakdownEvent event, Emitter<PricingState> emit) async {
    emit(const PricingLoadingState());
    final result =
        await repository.getCommissionBreakdown(event.month, event.year);
    result.fold(
      (failure) => emit(PricingErrorState(failure.message)),
      (breakdown) => emit(CommissionBreakdownSuccessState(breakdown)),
    );
  }

  Future<void> _onClearPricing(
      ClearPricingEvent event, Emitter<PricingState> emit) async {
    emit(const PricingInitialState());
  }
}
