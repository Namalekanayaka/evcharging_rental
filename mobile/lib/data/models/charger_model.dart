import 'package:equatable/equatable.dart';
import '../../domain/entities/charger_entity.dart';

class ChargerModel extends Equatable {
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

  const ChargerModel({
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

  factory ChargerModel.fromJson(Map<String, dynamic> json) {
    final connectorTypesJson =
        json['connectorTypes'] ?? json['connector_types'];
    List<String> connectorTypes = [];

    if (connectorTypesJson is List) {
      connectorTypes = List<String>.from(connectorTypesJson);
    } else if (connectorTypesJson is String) {
      connectorTypes = connectorTypesJson.split(',');
    }

    return ChargerModel(
      id: json['id'] as int,
      ownerId: json['ownerId'] ?? json['owner_id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: json['type'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      pricePerHour:
          (json['pricePerHour'] ?? json['price_per_hour'] as num).toDouble(),
      connectorTypes: connectorTypes,
      maxWattage: json['maxWattage'] ?? json['max_wattage'] as int,
      averageRating:
          (json['averageRating'] ?? json['average_rating'])?.toDouble(),
      totalReviews: json['totalReviews'] ?? json['total_reviews'] as int?,
      status: json['status'] as String? ?? 'active',
      createdAt:
          DateTime.parse(json['createdAt'] ?? json['created_at'] as String),
    );
  }

  ChargerEntity toEntity() {
    return ChargerEntity(
      id: id,
      ownerId: ownerId,
      name: name,
      description: description,
      type: type,
      address: address,
      latitude: latitude,
      longitude: longitude,
      pricePerHour: pricePerHour,
      connectorTypes: connectorTypes,
      maxWattage: maxWattage,
      averageRating: averageRating,
      totalReviews: totalReviews,
      status: status,
      createdAt: createdAt,
    );
  }

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
