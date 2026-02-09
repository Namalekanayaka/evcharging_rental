import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/charger_entity.dart';

part 'charger_event.dart';
part 'charger_state.dart';

class ChargerBloc extends Bloc<ChargerEvent, ChargerState> {
  ChargerBloc() : super(ChargerInitial()) {
    on<SearchChargersEvent>(_onSearchChargers);
    on<GetChargerDetailEvent>(_onGetDetail);
  }

  Future<void> _onSearchChargers(
      SearchChargersEvent event, Emitter<ChargerState> emit) async {
    emit(ChargerLoading());
    // TODO: Implement search logic
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _onGetDetail(
      GetChargerDetailEvent event, Emitter<ChargerState> emit) async {
    emit(ChargerLoading());
    // TODO: Implement detail fetching
    await Future.delayed(const Duration(seconds: 1));
  }
}
