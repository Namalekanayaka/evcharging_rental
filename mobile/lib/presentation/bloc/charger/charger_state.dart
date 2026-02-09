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
  final int totalCount;
  final int page;

  const ChargersLoaded({
    required this.chargers,
    required this.totalCount,
    required this.page,
  });

  @override
  List<Object?> get props => [chargers, totalCount, page];
}

class ChargerDetailLoaded extends ChargerState {
  final ChargerEntity charger;

  const ChargerDetailLoaded({required this.charger});

  @override
  List<Object?> get props => [charger];
}

class ChargerCreated extends ChargerState {
  final ChargerEntity charger;

  const ChargerCreated({required this.charger});

  @override
  List<Object?> get props => [charger];
}

class ChargerUpdated extends ChargerState {
  final ChargerEntity charger;

  const ChargerUpdated({required this.charger});

  @override
  List<Object?> get props => [charger];
}

class ChargerDeleted extends ChargerState {
  const ChargerDeleted();
}

class MyChargersLoaded extends ChargerState {
  final List<ChargerEntity> chargers;

  const MyChargersLoaded({required this.chargers});

  @override
  List<Object?> get props => [chargers];
}

class ChargerStatusUpdated extends ChargerState {
  final int chargerId;
  final String status;

  const ChargerStatusUpdated({
    required this.chargerId,
    required this.status,
  });

  @override
  List<Object?> get props => [chargerId, status];
}

class ChargerUsageHistoryLoaded extends ChargerState {
  final List<Map<String, dynamic>> usageHistory;
  final double totalRevenue;
  final int totalBookings;

  const ChargerUsageHistoryLoaded({
    required this.usageHistory,
    required this.totalRevenue,
    required this.totalBookings,
  });

  @override
  List<Object?> get props => [usageHistory, totalRevenue, totalBookings];
}

class ChargerFailure extends ChargerState {
  final String message;

  const ChargerFailure({required this.message});

  String get error => message;

  @override
  List<Object?> get props => [message];
}
