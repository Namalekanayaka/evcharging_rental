import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/entities/payment_entities.dart';
import '../../domain/usecases/payment_usecases.dart';

// ==================== EVENTS ====================

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class GetWalletEvent extends PaymentEvent {
  const GetWalletEvent();
}

class AddMoneyEvent extends PaymentEvent {
  final double amount;
  final String paymentMethod;

  const AddMoneyEvent({
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

class GetTransactionHistoryEvent extends PaymentEvent {
  final int limit;
  final int offset;
  final String? type;

  const GetTransactionHistoryEvent({
    this.limit = 20,
    this.offset = 0,
    this.type,
  });

  @override
  List<Object?> get props => [limit, offset, type];
}

class GetPaymentHistoryEvent extends PaymentEvent {
  final int limit;
  final int offset;

  const GetPaymentHistoryEvent({
    this.limit = 20,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [limit, offset];
}

class ProcessPaymentEvent extends PaymentEvent {
  final double amount;
  final int bookingId;
  final String paymentMethod;

  const ProcessPaymentEvent({
    required this.amount,
    required this.bookingId,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, bookingId, paymentMethod];
}

class GetPaymentDetailsEvent extends PaymentEvent {
  final int paymentId;

  const GetPaymentDetailsEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class RefundPaymentEvent extends PaymentEvent {
  final int paymentId;

  const RefundPaymentEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class ClearPaymentEvent extends PaymentEvent {
  const ClearPaymentEvent();
}

// ==================== STATES ====================

abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

class PaymentInitialState extends PaymentState {
  const PaymentInitialState();
}

class PaymentLoadingState extends PaymentState {
  const PaymentLoadingState();
}

class WalletSuccessState extends PaymentState {
  final WalletEntity wallet;

  const WalletSuccessState(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class TransactionHistorySuccessState extends PaymentState {
  final List<TransactionEntity> transactions;

  const TransactionHistorySuccessState(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class PaymentHistorySuccessState extends PaymentState {
  final List<PaymentEntity> payments;

  const PaymentHistorySuccessState(this.payments);

  @override
  List<Object?> get props => [payments];
}

class PaymentProcessedState extends PaymentState {
  final PaymentEntity payment;

  const PaymentProcessedState(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentDetailsSuccessState extends PaymentState {
  final PaymentEntity payment;

  const PaymentDetailsSuccessState(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentRefundedState extends PaymentState {
  final PaymentEntity payment;

  const PaymentRefundedState(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentErrorState extends PaymentState {
  final String message;

  const PaymentErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLoC ====================

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final GetWalletUseCase getWalletUseCase;
  final AddMoneyUseCase addMoneyUseCase;
  final GetTransactionHistoryUseCase getTransactionHistoryUseCase;
  final GetPaymentHistoryUseCase getPaymentHistoryUseCase;
  final ProcessPaymentUseCase processPaymentUseCase;
  final GetPaymentDetailsUseCase getPaymentDetailsUseCase;
  final RefundPaymentUseCase refundPaymentUseCase;

  PaymentBloc({
    required this.getWalletUseCase,
    required this.addMoneyUseCase,
    required this.getTransactionHistoryUseCase,
    required this.getPaymentHistoryUseCase,
    required this.processPaymentUseCase,
    required this.getPaymentDetailsUseCase,
    required this.refundPaymentUseCase,
  }) : super(const PaymentInitialState()) {
    on<GetWalletEvent>(_onGetWallet);
    on<AddMoneyEvent>(_onAddMoney);
    on<GetTransactionHistoryEvent>(_onGetTransactionHistory);
    on<GetPaymentHistoryEvent>(_onGetPaymentHistory);
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<GetPaymentDetailsEvent>(_onGetPaymentDetails);
    on<RefundPaymentEvent>(_onRefundPayment);
    on<ClearPaymentEvent>(_onClearPayment);
  }

  Future<void> _onGetWallet(
    GetWalletEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoadingState());
    final result = await getWalletUseCase.call();
    result.fold(
      (failure) => emit(PaymentErrorState(failure.message)),
      (wallet) => emit(WalletSuccessState(wallet)),
    );
  }

  Future<void> _onAddMoney(
    AddMoneyEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoadingState());
    final request = AddMoneyRequestEntity(
      amount: event.amount,
      paymentMethod: event.paymentMethod,
    );
    final result = await addMoneyUseCase.call(request);
    result.fold(
      (failure) => emit(PaymentErrorState(failure.message)),
      (wallet) => emit(WalletSuccessState(wallet)),
    );
  }

  Future<void> _onGetTransactionHistory(
    GetTransactionHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoadingState());
    final result = await getTransactionHistoryUseCase.call(
      limit: event.limit,
      offset: event.offset,
      type: event.type,
    );
    result.fold(
      (failure) => emit(PaymentErrorState(failure.message)),
      (transactions) => emit(TransactionHistorySuccessState(transactions)),
    );
  }

  Future<void> _onGetPaymentHistory(
    GetPaymentHistoryEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoadingState());
    final result = await getPaymentHistoryUseCase.call(
      limit: event.limit,
      offset: event.offset,
    );
    result.fold(
      (failure) => emit(PaymentErrorState(failure.message)),
      (payments) => emit(PaymentHistorySuccessState(payments)),
    );
  }

  Future<void> _onProcessPayment(
    ProcessPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoadingState());
    final result = await processPaymentUseCase.call(
      amount: event.amount,
      bookingId: event.bookingId,
      paymentMethod: event.paymentMethod,
    );
    result.fold(
      (failure) => emit(PaymentErrorState(failure.message)),
      (payment) => emit(PaymentProcessedState(payment)),
    );
  }

  Future<void> _onGetPaymentDetails(
    GetPaymentDetailsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoadingState());
    final result = await getPaymentDetailsUseCase.call(event.paymentId);
    result.fold(
      (failure) => emit(PaymentErrorState(failure.message)),
      (payment) => emit(PaymentDetailsSuccessState(payment)),
    );
  }

  Future<void> _onRefundPayment(
    RefundPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoadingState());
    final result = await refundPaymentUseCase.call(event.paymentId);
    result.fold(
      (failure) => emit(PaymentErrorState(failure.message)),
      (payment) => emit(PaymentRefundedState(payment)),
    );
  }

  Future<void> _onClearPayment(
    ClearPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentInitialState());
  }
}
