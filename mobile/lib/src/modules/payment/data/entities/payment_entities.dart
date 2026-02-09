import 'package:equatable/equatable.dart';

// Wallet Entity
class WalletEntity extends Equatable {
  final int id;
  final int userId;
  final double balance;
  final String currency;
  final DateTime lastUpdated;

  const WalletEntity({
    required this.id,
    required this.userId,
    required this.balance,
    required this.currency,
    required this.lastUpdated,
  });

  factory WalletEntity.fromJson(Map<String, dynamic> json) {
    return WalletEntity(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'balance': balance,
        'currency': currency,
        'last_updated': lastUpdated.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, userId, balance, currency, lastUpdated];
}

// Transaction Entity
class TransactionEntity extends Equatable {
  final int id;
  final int userId;
  final double amount;
  final String type; // 'credit' or 'debit'
  final String description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'type': type,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, userId, amount, type, description, createdAt];
}

// Payment Entity
class PaymentEntity extends Equatable {
  final int id;
  final int userId;
  final int? bookingId;
  final double amount;
  final String paymentMethod; // 'wallet', 'credit_card', 'debit_card'
  final String status; // 'pending', 'completed', 'refunded', 'failed'
  final DateTime createdAt;
  final String? chargerName;
  final DateTime? bookingStartTime;

  const PaymentEntity({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.chargerName,
    this.bookingStartTime,
  });

  factory PaymentEntity.fromJson(Map<String, dynamic> json) {
    return PaymentEntity(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      bookingId: json['booking_id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      chargerName: json['charger_name'] as String?,
      bookingStartTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'booking_id': bookingId,
        'amount': amount,
        'payment_method': paymentMethod,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'charger_name': chargerName,
        'start_time': bookingStartTime?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        userId,
        bookingId,
        amount,
        paymentMethod,
        status,
        createdAt,
        chargerName,
        bookingStartTime,
      ];
}

// Add Money Request Entity
class AddMoneyRequestEntity extends Equatable {
  final double amount;
  final String paymentMethod; // 'credit_card', 'debit_card', 'bank_transfer'

  const AddMoneyRequestEntity({
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'payment_method': paymentMethod,
      };

  @override
  List<Object?> get props => [amount, paymentMethod];
}

// Transaction History Request Entity
class TransactionHistoryRequestEntity extends Equatable {
  final int limit;
  final int offset;
  final String? type; // 'credit', 'debit', or null for all

  const TransactionHistoryRequestEntity({
    this.limit = 20,
    this.offset = 0,
    this.type,
  });

  Map<String, dynamic> toJson() => {
        'limit': limit,
        'offset': offset,
        if (type != null) 'type': type,
      };

  @override
  List<Object?> get props => [limit, offset, type];
}

// Payment History Request Entity
class PaymentHistoryRequestEntity extends Equatable {
  final int limit;
  final int offset;

  const PaymentHistoryRequestEntity({
    this.limit = 20,
    this.offset = 0,
  });

  Map<String, dynamic> toJson() => {
        'limit': limit,
        'offset': offset,
      };

  @override
  List<Object?> get props => [limit, offset];
}
