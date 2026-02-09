part of 'charger_bloc.dart';

abstract class ChargerState extends Equatable {
  const ChargerState();

  @override
  List<Object?> get props => [];
}

class ChargerInitial extends ChargerState {
  const ChargerInitial();
}

class ChargerLoading extends ChargerState {
  const ChargerLoading();
}

class ChargersLoaded extends ChargerState {
  final List<ChargerEntity> chargers;

  const ChargersLoaded({required this.chargers});

  @override
  List<Object?> get props => [chargers];
}

class ChargerDetailLoaded extends ChargerState {
  final ChargerEntity charger;

  const ChargerDetailLoaded({required this.charger});

  @override
  List<Object?> get props => [charger];
}

class ChargerFailure extends ChargerState {
  final String message;

  const ChargerFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
