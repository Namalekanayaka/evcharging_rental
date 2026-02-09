import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final int id;
  final int userId;
  final int bookingId;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        bookingId,
        amount,
        paymentMethod,
        status,
        createdAt,
      ];
}
