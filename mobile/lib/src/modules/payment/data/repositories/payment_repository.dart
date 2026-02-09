import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../datasources/payment_remote_data_source.dart';
import '../entities/payment_entities.dart';

abstract class PaymentRepository {
  Future<Either<Failure, WalletEntity>> getWallet();
  Future<Either<Failure, WalletEntity>> addMoney(AddMoneyRequestEntity request);
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory({
    required int limit,
    required int offset,
    String? type,
  });
  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory({
    required int limit,
    required int offset,
  });
  Future<Either<Failure, PaymentEntity>> processPayment({
    required double amount,
    required int bookingId,
    required String paymentMethod,
  });
  Future<Either<Failure, PaymentEntity>> getPayment(int paymentId);
  Future<Either<Failure, PaymentEntity>> refundPayment(int paymentId);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalletEntity>> getWallet() async {
    try {
      final wallet = await remoteDataSource.getWallet();
      return Right(wallet);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, WalletEntity>> addMoney(
    AddMoneyRequestEntity request,
  ) async {
    try {
      final wallet = await remoteDataSource.addMoney(request);
      return Right(wallet);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactionHistory({
    required int limit,
    required int offset,
    String? type,
  }) async {
    try {
      final transactions = await remoteDataSource.getTransactionHistory(
        limit: limit,
        offset: offset,
        type: type,
      );
      return Right(transactions);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, List<PaymentEntity>>> getPaymentHistory({
    required int limit,
    required int offset,
  }) async {
    try {
      final payments = await remoteDataSource.getPaymentHistory(
        limit: limit,
        offset: offset,
      );
      return Right(payments);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> processPayment({
    required double amount,
    required int bookingId,
    required String paymentMethod,
  }) async {
    try {
      final payment = await remoteDataSource.processPayment(
        amount: amount,
        bookingId: bookingId,
        paymentMethod: paymentMethod,
      );
      return Right(payment);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> getPayment(int paymentId) async {
    try {
      final payment = await remoteDataSource.getPayment(paymentId);
      return Right(payment);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> refundPayment(
    int paymentId,
  ) async {
    try {
      final payment = await remoteDataSource.refundPayment(paymentId);
      return Right(payment);
    } catch (e) {
      return Left(
        ApiFailure(message: e.toString()),
      );
    }
  }
}
