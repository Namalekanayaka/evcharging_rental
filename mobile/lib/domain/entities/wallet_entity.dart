import 'package:equatable/equatable.dart';

class WalletEntity extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final DateTime createdAt;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.balance,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, balance, createdAt];
}

class WalletTransactionEntity extends Equatable {
  final int id;
  final int userId;
  final double amount;
  final String type;
  final String description;
  final DateTime createdAt;

  const WalletTransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, amount, type, description, createdAt];
}
