import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../entities/search_entities.dart';
import '../usecases/search_usecases.dart';

// Events
abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchNearbyEvent extends SearchEvent {
  final SearchFilterEntity filters;

  const SearchNearbyEvent({required this.filters});

  @override
  List<Object?> get props => [filters];
}

class GetRecommendationEvent extends SearchEvent {
  final double latitude;
  final double longitude;
  final int? batteryPercentage;
  final bool urgentCharging;

  const GetRecommendationEvent({
    required this.latitude,
    required this.longitude,
    this.batteryPercentage,
    this.urgentCharging = false,
  });

  @override
  List<Object?> get props => [latitude, longitude, batteryPercentage, urgentCharging];
}

class SearchByLocationEvent extends SearchEvent {
  final String query;
  final int limit;
  final int offset;

  const SearchByLocationEvent({
    required this.query,
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [query, limit, offset];
}

class GetAvailabilityEvent extends SearchEvent {
  final int chargerId;

  const GetAvailabilityEvent({required this.chargerId});

  @override
  List<Object?> get props => [chargerId];
}

class GetChargersInAreaEvent extends SearchEvent {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  const GetChargersInAreaEvent({
    required this.minLat,
    required this.maxLat,
    required this.minLng,
    required this.maxLng,
  });

  @override
  List<Object?> get props => [minLat, maxLat, minLng, maxLng];
}

class CalculateRouteEvent extends SearchEvent {
  final double fromLat;
  final double fromLng;
  final double toLat;
  final double toLng;

  const CalculateRouteEvent({
    required this.fromLat,
    required this.fromLng,
    required this.toLat,
    required this.toLng,
  });

  @override
  List<Object?> get props => [fromLat, fromLng, toLat, toLng];
}

class GetTrendingChargersEvent extends SearchEvent {
  final int limit;
  final int radiusKm;

  const GetTrendingChargersEvent({
    this.limit = 10,
    this.radiusKm = 50,
  });

  @override
  List<Object?> get props => [limit, radiusKm];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitialState extends SearchState {
  const SearchInitialState();
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

class SearchSuccessState extends SearchState {
  final List<ChargerSearchResultEntity> chargers;
  final String message;

  const SearchSuccessState({
    required this.chargers,
    this.message = 'Search completed',
  });

  @override
  List<Object?> get props => [chargers, message];
}

class RecommendationSuccessState extends SearchState {
  final ChargerSearchResultEntity? charger;

  const RecommendationSuccessState({this.charger});

  @override
  List<Object?> get props => [charger];
}

class LocationSearchSuccessState extends SearchState {
  final List<ChargerSearchResultEntity> chargers;

  const LocationSearchSuccessState({required this.chargers});

  @override
  List<Object?> get props => [chargers];
}

class AvailabilitySuccessState extends SearchState {
  final AvailabilityEntity availability;

  const AvailabilitySuccessState({required this.availability});

  @override
  List<Object?> get props => [availability];
}

class AreaSearchSuccessState extends SearchState {
  final List<ChargerSearchResultEntity> chargers;

  const AreaSearchSuccessState({required this.chargers});

  @override
  List<Object?> get props => [chargers];
}

class RouteCalculatedState extends SearchState {
  final RouteInfoEntity route;

  const RouteCalculatedState({required this.route});

  @override
  List<Object?> get props => [route];
}

class TrendingChargersSuccessState extends SearchState {
  final List<ChargerSearchResultEntity> chargers;

  const TrendingChargersSuccessState({required this.chargers});

  @override
  List<Object?> get props => [chargers];
}

class SearchErrorState extends SearchState {
  final String message;

  const SearchErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchNearbyChargersUseCase searchNearbyChargersUseCase;
  final GetRecommendedChargerUseCase getRecommendedChargerUseCase;
  final SearchByLocationUseCase searchByLocationUseCase;
  final GetChargerAvailabilityUseCase getChargerAvailabilityUseCase;
  final GetChargersInAreaUseCase getChargersInAreaUseCase;
  final CalculateRouteUseCase calculateRouteUseCase;
  final GetTrendingChargersUseCase getTrendingChargersUseCase;

  SearchBloc({
    required this.searchNearbyChargersUseCase,
    required this.getRecommendedChargerUseCase,
    required this.searchByLocationUseCase,
    required this.getChargerAvailabilityUseCase,
    required this.getChargersInAreaUseCase,
    required this.calculateRouteUseCase,
    required this.getTrendingChargersUseCase,
  }) : super(const SearchInitialState()) {
    on<SearchNearbyEvent>(_onSearchNearby);
    on<GetRecommendationEvent>(_onGetRecommendation);
    on<SearchByLocationEvent>(_onSearchByLocation);
    on<GetAvailabilityEvent>(_onGetAvailability);
    on<GetChargersInAreaEvent>(_onGetChargersInArea);
    on<CalculateRouteEvent>(_onCalculateRoute);
    on<GetTrendingChargersEvent>(_onGetTrendingChargers);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchNearby(
    SearchNearbyEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    final result = await searchNearbyChargersUseCase(event.filters);

    result.fold(
      (failure) => emit(SearchErrorState(message: failure.message)),
      (chargers) => emit(SearchSuccessState(chargers: chargers)),
    );
  }

  Future<void> _onGetRecommendation(
    GetRecommendationEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    final params = GetRecommendedChargerParams(
      latitude: event.latitude,
      longitude: event.longitude,
      batteryPercentage: event.batteryPercentage,
      urgentCharging: event.urgentCharging,
    );

    final result = await getRecommendedChargerUseCase(params);

    result.fold(
      (failure) => emit(SearchErrorState(message: failure.message)),
      (charger) => emit(RecommendationSuccessState(charger: charger)),
    );
  }

  Future<void> _onSearchByLocation(
    SearchByLocationEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    final params = SearchByLocationParams(
      query: event.query,
      limit: event.limit,
      offset: event.offset,
    );

    final result = await searchByLocationUseCase(params);

    result.fold(
      (failure) => emit(SearchErrorState(message: failure.message)),
      (chargers) => emit(LocationSearchSuccessState(chargers: chargers)),
    );
  }

  Future<void> _onGetAvailability(
    GetAvailabilityEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    final result = await getChargerAvailabilityUseCase(event.chargerId);

    result.fold(
      (failure) => emit(SearchErrorState(message: failure.message)),
      (availability) => emit(AvailabilitySuccessState(availability: availability)),
    );
  }

  Future<void> _onGetChargersInArea(
    GetChargersInAreaEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    final params = GetChargersInAreaParams(
      minLat: event.minLat,
      maxLat: event.maxLat,
      minLng: event.minLng,
      maxLng: event.maxLng,
    );

    final result = await getChargersInAreaUseCase(params);

    result.fold(
      (failure) => emit(SearchErrorState(message: failure.message)),
      (chargers) => emit(AreaSearchSuccessState(chargers: chargers)),
    );
  }

  Future<void> _onCalculateRoute(
    CalculateRouteEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    final params = CalculateRouteParams(
      fromLat: event.fromLat,
      fromLng: event.fromLng,
      toLat: event.toLat,
      toLng: event.toLng,
    );

    final result = await calculateRouteUseCase(params);

    result.fold(
      (failure) => emit(SearchErrorState(message: failure.message)),
      (route) => emit(RouteCalculatedState(route: route)),
    );
  }

  Future<void> _onGetTrendingChargers(
    GetTrendingChargersEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchLoadingState());

    final params = GetTrendingChargersParams(
      limit: event.limit,
      radiusKm: event.radiusKm,
    );

    final result = await getTrendingChargersUseCase(params);

    result.fold(
      (failure) => emit(SearchErrorState(message: failure.message)),
      (chargers) => emit(TrendingChargersSuccessState(chargers: chargers)),
    );
  }

  Future<void> _onClearSearch(
    ClearSearchEvent event,
    Emitter<SearchState> emit,
  ) async {
    emit(const SearchInitialState());
  }
}
