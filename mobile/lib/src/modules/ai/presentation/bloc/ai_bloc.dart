import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repositories/ai_repository.dart';
import '../../domain/entities/ai_entities.dart';

// ==================== EVENTS ====================

abstract class AIEvent extends Equatable {
  const AIEvent();
  @override
  List<Object?> get props => [];
}

class PredictBatteryRangeEvent extends AIEvent {
  final String carModel;
  final double currentBattery;
  final String? weather;

  const PredictBatteryRangeEvent(this.carModel, this.currentBattery, {this.weather});
  @override
  List<Object?> get props => [carModel, currentBattery, weather];
}

class FindNearestChargersEvent extends AIEvent {
  final double latitude;
  final double longitude;
  final double currentBattery;
  final String carModel;
  final String? weather;

  const FindNearestChargersEvent(
    this.latitude,
    this.longitude,
    this.currentBattery,
    this.carModel, {
    this.weather,
  });
  @override
  List<Object?> get props => [latitude, longitude, currentBattery, carModel, weather];
}

class PredictDemandPricingEvent extends AIEvent {
  final int chargerId;
  final String? dateTime;

  const PredictDemandPricingEvent(this.chargerId, {this.dateTime});
  @override
  List<Object?> get props => [chargerId, dateTime];
}

class OptimizeRouteEvent extends AIEvent {
  final List<Map<String, dynamic>> locations;
  final String carModel;
  final double currentBattery;
  final String? weather;

  const OptimizeRouteEvent(
    this.locations,
    this.carModel,
    this.currentBattery, {
    this.weather,
  });
  @override
  List<Object?> get props => [locations, carModel, currentBattery, weather];
}

class GetRecommendationsEvent extends AIEvent {
  const GetRecommendationsEvent();
}

class ClearAIEvent extends AIEvent {
  const ClearAIEvent();
}

// ==================== STATES ====================

abstract class AIState extends Equatable {
  const AIState();
  @override
  List<Object?> get props => [];
}

class AIInitialState extends AIState {
  const AIInitialState();
}

class AILoadingState extends AIState {
  const AILoadingState();
}

class BatteryRangePredictedState extends AIState {
  final BatteryRangeEntity batteryRange;

  const BatteryRangePredictedState(this.batteryRange);
  @override
  List<Object?> get props => [batteryRange];
}

class NearestChargersFoundState extends AIState {
  final List<ChargerRecommendationEntity> chargers;

  const NearestChargersFoundState(this.chargers);
  @override
  List<Object?> get props => [chargers];
}

class DemandPricingPredictedState extends AIState {
  final DemandPricingEntity pricing;

  const DemandPricingPredictedState(this.pricing);
  @override
  List<Object?> get props => [pricing];
}

class RouteOptimizedState extends AIState {
  final OptimizedRouteEntity route;

  const RouteOptimizedState(this.route);
  @override
  List<Object?> get props => [route];
}

class RecommendationsReceivedState extends AIState {
  final List<AIRecommendationEntity> recommendations;

  const RecommendationsReceivedState(this.recommendations);
  @override
  List<Object?> get props => [recommendations];
}

class AIErrorState extends AIState {
  final String message;

  const AIErrorState(this.message);
  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class AIBloc extends Bloc<AIEvent, AIState> {
  final AIRepository repository;

  AIBloc({required this.repository}) : super(const AIInitialState()) {
    on<PredictBatteryRangeEvent>(_onPredictBatteryRange);
    on<FindNearestChargersEvent>(_onFindNearestChargers);
    on<PredictDemandPricingEvent>(_onPredictDemandPricing);
    on<OptimizeRouteEvent>(_onOptimizeRoute);
    on<GetRecommendationsEvent>(_onGetRecommendations);
    on<ClearAIEvent>(_onClear);
  }

  Future<void> _onPredictBatteryRange(
    PredictBatteryRangeEvent event,
    Emitter<AIState> emit,
  ) async {
    emit(const AILoadingState());
    final result = await repository.predictBatteryRange(
      event.carModel,
      event.currentBattery,
      weather: event.weather,
    );
    result.fold(
      (failure) => emit(AIErrorState(failure.message)),
      (batteryRange) => emit(BatteryRangePredictedState(batteryRange)),
    );
  }

  Future<void> _onFindNearestChargers(
    FindNearestChargersEvent event,
    Emitter<AIState> emit,
  ) async {
    emit(const AILoadingState());
    final result = await repository.findNearestChargers(
      event.latitude,
      event.longitude,
      event.currentBattery,
      event.carModel,
      weather: event.weather,
    );
    result.fold(
      (failure) => emit(AIErrorState(failure.message)),
      (chargers) => emit(NearestChargersFoundState(chargers)),
    );
  }

  Future<void> _onPredictDemandPricing(
    PredictDemandPricingEvent event,
    Emitter<AIState> emit,
  ) async {
    emit(const AILoadingState());
    final result = await repository.predictDemandPricing(
      event.chargerId,
      dateTime: event.dateTime,
    );
    result.fold(
      (failure) => emit(AIErrorState(failure.message)),
      (pricing) => emit(DemandPricingPredictedState(pricing)),
    );
  }

  Future<void> _onOptimizeRoute(
    OptimizeRouteEvent event,
    Emitter<AIState> emit,
  ) async {
    emit(const AILoadingState());
    final result = await repository.optimizeRoute(
      event.locations,
      event.carModel,
      event.currentBattery,
      weather: event.weather,
    );
    result.fold(
      (failure) => emit(AIErrorState(failure.message)),
      (route) => emit(RouteOptimizedState(route)),
    );
  }

  Future<void> _onGetRecommendations(
    GetRecommendationsEvent event,
    Emitter<AIState> emit,
  ) async {
    emit(const AILoadingState());
    final result = await repository.getRecommendations();
    result.fold(
      (failure) => emit(AIErrorState(failure.message)),
      (recommendations) => emit(RecommendationsReceivedState(recommendations)),
    );
  }

  void _onClear(
    ClearAIEvent event,
    Emitter<AIState> emit,
  ) {
    emit(const AIInitialState());
  }
}
