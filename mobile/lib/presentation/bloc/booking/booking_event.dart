part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final int chargerId;
  final DateTime startTime;
  final int duration;
  final double totalAmount;

  const CreateBookingEvent({
    required this.chargerId,
    required this.startTime,
    required this.duration,
    required this.totalAmount,
  });

  @override
  List<Object> get props => [chargerId, startTime, duration, totalAmount];
}

class FetchBookingsEvent extends BookingEvent {
  final String? status;

  const FetchBookingsEvent({this.status});

  @override
  List<Object?> get props => [status];
}

class CancelBookingEvent extends BookingEvent {
  final int bookingId;
  final String reason;

  const CancelBookingEvent({required this.bookingId, required this.reason});

  @override
  List<Object> get props => [bookingId, reason];
}
