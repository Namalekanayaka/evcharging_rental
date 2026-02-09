part of 'charger_bloc.dart';

abstract class ChargerEvent extends Equatable {
  const ChargerEvent();

  @override
  List<Object?> get props => [];
}

class SearchChargersEvent extends ChargerEvent {
  final double? latitude;
  final double? longitude;
  final double? radius;
  final double? minPrice;
  final double? maxPrice;
  final String? connectorType;

  const SearchChargersEvent({
    this.latitude,
    this.longitude,
    this.radius,
    this.minPrice,
    this.maxPrice,
    this.connectorType,
  });

  @override
  List<Object?> get props =>
      [latitude, longitude, radius, minPrice, maxPrice, connectorType];
}

class GetChargerDetailEvent extends ChargerEvent {
  final int chargerId;

  const GetChargerDetailEvent({required this.chargerId});

  @override
  List<Object> get props => [chargerId];
}
