import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final int id;
  final int userId;
  final int chargerId;
  final String chargerName;
  final String address;
  final DateTime startTime;
  final DateTime endTime;
  final int duration;
  final double totalAmount;
  final String status;
  final String? cancellationReason;
  final DateTime? completedAt;
  final DateTime createdAt;

  const BookingEntity({
    required this.id,
    required this.userId,
    required this.chargerId,
    required this.chargerName,
    required this.address,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.totalAmount,
    required this.status,
    this.cancellationReason,
    this.completedAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        chargerId,
        chargerName,
        address,
        startTime,
        endTime,
        duration,
        totalAmount,
        status,
        cancellationReason,
        completedAt,
        createdAt,
      ];
}
