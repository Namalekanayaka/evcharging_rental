import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/booking_entity.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc() : super(const BookingInitial()) {
    on<CreateBookingEvent>(_onCreate);
    on<FetchBookingsEvent>(_onFetch);
    on<CancelBookingEvent>(_onCancel);
  }

  Future<void> _onCreate(
      CreateBookingEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());
    // TODO: Implement booking creation
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _onFetch(
      FetchBookingsEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());
    // TODO: Implement booking fetching
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> _onCancel(
      CancelBookingEvent event, Emitter<BookingState> emit) async {
    emit(const BookingLoading());
    // TODO: Implement booking cancellation
    await Future.delayed(const Duration(seconds: 1));
  }
}
