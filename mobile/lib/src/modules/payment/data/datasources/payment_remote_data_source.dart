import 'package:dio/dio.dart';
import '../entities/payment_entities.dart';

abstract class PaymentRemoteDataSource {
  /// Get wallet balance and info
  Future<WalletEntity> getWallet();

  /// Add money to wallet
  Future<WalletEntity> addMoney(AddMoneyRequestEntity request);

  /// Get transaction history
  Future<List<TransactionEntity>> getTransactionHistory({
    required int limit,
    required int offset,
    String? type,
  });

  /// Get payment history for user
  Future<List<PaymentEntity>> getPaymentHistory({
    required int limit,
    required int offset,
  });

  /// Process payment for booking
  Future<PaymentEntity> processPayment({
    required double amount,
    required int bookingId,
    required String paymentMethod,
  });

  /// Get single payment details
  Future<PaymentEntity> getPayment(int paymentId);

  /// Refund payment
  Future<PaymentEntity> refundPayment(int paymentId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  PaymentRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<WalletEntity> getWallet() async {
    try {
      final response = await dio.get(
        '$baseUrl/wallet',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return WalletEntity.fromJson(data);
      } else {
        throw Exception('Failed to get wallet');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to get wallet');
    }
  }

  @override
  Future<WalletEntity> addMoney(AddMoneyRequestEntity request) async {
    try {
      final response = await dio.post(
        '$baseUrl/wallet/add-money',
        data: request.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return WalletEntity.fromJson(data);
      } else {
        throw Exception('Failed to add money');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to add money');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionHistory({
    required int limit,
    required int offset,
    String? type,
  }) async {
    try {
      final queryParams = {
        'limit': limit,
        'offset': offset,
        if (type != null) 'type': type,
      };

      final response = await dio.get(
        '$baseUrl/wallet/transactions',
        queryParameters: queryParams,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final dataList = (response.data['data'] as List)
            .map((item) =>
                TransactionEntity.fromJson(item as Map<String, dynamic>))
            .toList();
        return dataList;
      } else {
        throw Exception('Failed to get transaction history');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to get transaction history');
    }
  }

  @override
  Future<List<PaymentEntity>> getPaymentHistory({
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/payments',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final dataList = (response.data['data'] as List)
            .map((item) => PaymentEntity.fromJson(item as Map<String, dynamic>))
            .toList();
        return dataList;
      } else {
        throw Exception('Failed to get payment history');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to get payment history');
    }
  }

  @override
  Future<PaymentEntity> processPayment({
    required double amount,
    required int bookingId,
    required String paymentMethod,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/payments/process',
        data: {
          'amount': amount,
          'booking_id': bookingId,
          'payment_method': paymentMethod,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaymentEntity.fromJson(data);
      } else {
        throw Exception('Failed to process payment');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to process payment');
    }
  }

  @override
  Future<PaymentEntity> getPayment(int paymentId) async {
    try {
      final response = await dio.get(
        '$baseUrl/payments/$paymentId',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaymentEntity.fromJson(data);
      } else {
        throw Exception('Payment not found');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to get payment');
    }
  }

  @override
  Future<PaymentEntity> refundPayment(int paymentId) async {
    try {
      final response = await dio.post(
        '$baseUrl/payments/$paymentId/refund',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return PaymentEntity.fromJson(data);
      } else {
        throw Exception('Failed to refund payment');
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Failed to refund payment');
    }
  }
}
