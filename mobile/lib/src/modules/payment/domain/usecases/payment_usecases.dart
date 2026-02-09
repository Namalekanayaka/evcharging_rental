import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../data/entities/payment_entities.dart';
import '../../data/repositories/payment_repository.dart';

// Get Wallet Use Case
class GetWalletUseCase {
  final PaymentRepository repository;

  GetWalletUseCase({required this.repository});

  Future<Either<Failure, WalletEntity>> call() async {
    return await repository.getWallet();
  }
}

// Add Money Use Case
class AddMoneyUseCase {
  final PaymentRepository repository;

  AddMoneyUseCase({required this.repository});

  Future<Either<Failure, WalletEntity>> call(
    AddMoneyRequestEntity request,
  ) async {
    return await repository.addMoney(request);
  }
}

// Get Transaction History Use Case
class GetTransactionHistoryUseCase {
  final PaymentRepository repository;

  GetTransactionHistoryUseCase({required this.repository});

  Future<Either<Failure, List<TransactionEntity>>> call({
    required int limit,
    required int offset,
    String? type,
  }) async {
    return await repository.getTransactionHistory(
      limit: limit,
      offset: offset,
      type: type,
    );
  }
}

// Get Payment History Use Case
class GetPaymentHistoryUseCase {
  final PaymentRepository repository;

  GetPaymentHistoryUseCase({required this.repository});

  Future<Either<Failure, List<PaymentEntity>>> call({
    required int limit,
    required int offset,
  }) async {
    return await repository.getPaymentHistory(
      limit: limit,
      offset: offset,
    );
  }
}

// Process Payment Use Case
class ProcessPaymentUseCase {
  final PaymentRepository repository;

  ProcessPaymentUseCase({required this.repository});

  Future<Either<Failure, PaymentEntity>> call({
    required double amount,
    required int bookingId,
    required String paymentMethod,
  }) async {
    return await repository.processPayment(
      amount: amount,
      bookingId: bookingId,
      paymentMethod: paymentMethod,
    );
  }
}

// Get Payment Details Use Case
class GetPaymentDetailsUseCase {
  final PaymentRepository repository;

  GetPaymentDetailsUseCase({required this.repository});

  Future<Either<Failure, PaymentEntity>> call(int paymentId) async {
    return await repository.getPayment(paymentId);
  }
}

// Refund Payment Use Case
class RefundPaymentUseCase {
  final PaymentRepository repository;

  RefundPaymentUseCase({required this.repository});

  Future<Either<Failure, PaymentEntity>> call(int paymentId) async {
    return await repository.refundPayment(paymentId);
  }
}
