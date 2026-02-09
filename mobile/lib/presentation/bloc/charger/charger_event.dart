part of 'charger_bloc.dart';

abstract class ChargerEvent extends Equatable {
  const ChargerEvent();

  @override
  List<Object?> get props => [];
}

/// Search chargers with filters
class SearchChargersEvent extends ChargerEvent {
  final double? latitude;
  final double? longitude;
  final double? radius;
  final double? minPrice;
  final double? maxPrice;
  final String? chargerType;
  final String? city;
  final String? sortBy;
  final int page;

  const SearchChargersEvent({
    this.latitude,
    this.longitude,
    this.radius,
    this.minPrice,
    this.maxPrice,
    this.chargerType,
    this.city,
    this.sortBy = 'DISTANCE',
    this.page = 1,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radius,
    minPrice,
    maxPrice,
    chargerType,
    city,
    sortBy,
    page,
  ];
}

/// Get charger details
class GetChargerDetailEvent extends ChargerEvent {
  final int chargerId;

  const GetChargerDetailEvent({required this.chargerId});

  @override
  List<Object> get props => [chargerId];
}

/// Create new charger
class CreateChargerEvent extends ChargerEvent {
  final String name;
  final String description;
  final String type;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final double pricePerKwh;
  final double pricePerHour;
  final double powerKw;
  final bool isPublic;
  final bool allowReservations;

  const CreateChargerEvent({
    required this.name,
    required this.description,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.pricePerKwh,
    required this.pricePerHour,
    required this.powerKw,
    required this.isPublic,
    required this.allowReservations,
  });

  @override
  List<Object> get props => [
    name,
    description,
    type,
    address,
    latitude,
    longitude,
    pricePerKwh,
    pricePerHour,
    powerKw,
  ];
}

/// Update existing charger
class UpdateChargerEvent extends ChargerEvent {
  final int chargerId;
  final String name;
  final String description;
  final String type;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final double pricePerKwh;
  final double pricePerHour;
  final double powerKw;
  final bool isPublic;
  final bool allowReservations;

  const UpdateChargerEvent({
    required this.chargerId,
    required this.name,
    required this.description,
    required this.type,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    required this.pricePerKwh,
    required this.pricePerHour,
    required this.powerKw,
    required this.isPublic,
    required this.allowReservations,
  });

  @override
  List<Object> get props => [chargerId, name];
}

/// Delete charger
class DeleteChargerEvent extends ChargerEvent {
  final int chargerId;

  const DeleteChargerEvent({required this.chargerId});

  @override
  List<Object> get props => [chargerId];
}

/// Get operator's chargers
class GetMyChargersEvent extends ChargerEvent {
  const GetMyChargersEvent();
}

/// Update charger status
class UpdateChargerStatusEvent extends ChargerEvent {
  final int chargerId;
  final String status;

  const UpdateChargerStatusEvent({
    required this.chargerId,
    required this.status,
  });

  @override
  List<Object> get props => [chargerId, status];
}

/// Get charger usage history
class GetChargerUsageHistoryEvent extends ChargerEvent {
  final int chargerId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetChargerUsageHistoryEvent({
    required this.chargerId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [chargerId, startDate, endDate];
}
