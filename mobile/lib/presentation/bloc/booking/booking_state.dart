part of 'booking_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingCreated extends BookingState {
  final BookingEntity booking;

  const BookingCreated({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingsLoaded extends BookingState {
  final List<BookingEntity> bookings;

  const BookingsLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class BookingCancelled extends BookingState {
  const BookingCancelled();
}

class BookingFailure extends BookingState {
  final String message;

  const BookingFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
