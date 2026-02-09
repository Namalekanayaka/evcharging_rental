import 'package:equatable/equatable.dart';

class ChargerEntity extends Equatable {
  final int id;
  final int ownerId;
  final String name;
  final String description;
  final String type;
  final String address;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final List<String> connectorTypes;
  final int maxWattage;
  final double? averageRating;
  final int? totalReviews;
  final String status;
  final DateTime createdAt;

  const ChargerEntity({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.connectorTypes,
    required this.maxWattage,
    this.averageRating,
    this.totalReviews,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        ownerId,
        name,
        description,
        type,
        address,
        latitude,
        longitude,
        pricePerHour,
        connectorTypes,
        maxWattage,
        averageRating,
        totalReviews,
        status,
        createdAt,
      ];
}
