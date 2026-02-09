import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/charger_entity.dart';
import '../../../data/repositories/charger_repository.dart';

part 'charger_event.dart';
part 'charger_state.dart';

class ChargerBloc extends Bloc<ChargerEvent, ChargerState> {
  final ChargerRepository _chargerRepository;

  ChargerBloc({required ChargerRepository chargerRepository})
      : _chargerRepository = chargerRepository,
        super(const ChargerInitial()) {
    on<SearchChargersEvent>(_onSearchChargers);
    on<GetChargerDetailEvent>(_onGetDetail);
    on<CreateChargerEvent>(_onCreate);
    on<UpdateChargerEvent>(_onUpdate);
    on<DeleteChargerEvent>(_onDelete);
    on<GetMyChargersEvent>(_onGetMyChargers);
    on<UpdateChargerStatusEvent>(_onUpdateStatus);
    on<GetChargerUsageHistoryEvent>(_onGetUsageHistory);
  }

  /// Search chargers
  Future<void> _onSearchChargers(
    SearchChargersEvent event,
    Emitter<ChargerState> emit,
  ) async {
    emit(const ChargerLoading());
    try {
      final result = await _chargerRepository.searchChargers(
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
        chargerType: event.chargerType,
        city: event.city,
        sortBy: event.sortBy,
        page: event.page,
      );

      emit(ChargersLoaded(
        chargers: result['chargers'],
        totalCount: result['totalCount'],
        page: event.page,
      ));
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }

  /// Get charger detail
  Future<void> _onGetDetail(
    GetChargerDetailEvent event,
    Emitter<ChargerState> emit,
  ) async {
    emit(const ChargerLoading());
    try {
      final charger = await _chargerRepository.getChargerDetail(event.chargerId);
      emit(ChargerDetailLoaded(charger: charger));
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }

  /// Create charger
  Future<void> _onCreate(
    CreateChargerEvent event,
    Emitter<ChargerState> emit,
  ) async {
    emit(const ChargerLoading());
    try {
      final charger = await _chargerRepository.createCharger(
        name: event.name,
        description: event.description,
        type: event.type,
        address: event.address,
        city: event.city,
        state: event.state,
        postalCode: event.postalCode,
        latitude: event.latitude,
        longitude: event.longitude,
        pricePerKwh: event.pricePerKwh,
        pricePerHour: event.pricePerHour,
        powerKw: event.powerKw,
        isPublic: event.isPublic,
        allowReservations: event.allowReservations,
      );
      emit(ChargerCreated(charger: charger));
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }

  /// Update charger
  Future<void> _onUpdate(
    UpdateChargerEvent event,
    Emitter<ChargerState> emit,
  ) async {
    emit(const ChargerLoading());
    try {
      final charger = await _chargerRepository.updateCharger(
        chargerId: event.chargerId,
        name: event.name,
        description: event.description,
        type: event.type,
        address: event.address,
        city: event.city,
        state: event.state,
        postalCode: event.postalCode,
        latitude: event.latitude,
        longitude: event.longitude,
        pricePerKwh: event.pricePerKwh,
        pricePerHour: event.pricePerHour,
        powerKw: event.powerKw,
        isPublic: event.isPublic,
        allowReservations: event.allowReservations,
      );
      emit(ChargerUpdated(charger: charger));
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }

  /// Delete charger
  Future<void> _onDelete(
    DeleteChargerEvent event,
    Emitter<ChargerState> emit,
  ) async {
    try {
      await _chargerRepository.deleteCharger(event.chargerId);
      emit(const ChargerDeleted());
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }

  /// Get my chargers
  Future<void> _onGetMyChargers(
    GetMyChargersEvent event,
    Emitter<ChargerState> emit,
  ) async {
    emit(const ChargerLoading());
    try {
      final chargers = await _chargerRepository.getMyChargers();
      emit(MyChargersLoaded(chargers: chargers));
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }

  /// Update charger status
  Future<void> _onUpdateStatus(
    UpdateChargerStatusEvent event,
    Emitter<ChargerState> emit,
  ) async {
    try {
      await _chargerRepository.updateChargerStatus(event.chargerId, event.status);
      emit(ChargerStatusUpdated(chargerId: event.chargerId, status: event.status));
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }

  /// Get usage history
  Future<void> _onGetUsageHistory(
    GetChargerUsageHistoryEvent event,
    Emitter<ChargerState> emit,
  ) async {
    emit(const ChargerLoading());
    try {
      final result = await _chargerRepository.getChargerUsageHistory(
        chargerId: event.chargerId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(ChargerUsageHistoryLoaded(
        usageHistory: result['usageHistory'],
        totalRevenue: result['totalRevenue'],
        totalBookings: result['totalBookings'],
      ));
    } catch (e) {
      emit(ChargerFailure(message: e.toString()));
    }
  }
}
