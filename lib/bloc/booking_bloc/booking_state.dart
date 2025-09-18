import 'package:web_flutter/model/booking/booking.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingCreated extends BookingState {
  final Booking booking;

  BookingCreated(this.booking);
}

class BookingLoaded extends BookingState {
  final List<Booking> bookings;

  BookingLoaded(this.bookings);
}

class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}

class BookingCancelled extends BookingState {
  final int bookingId;

  BookingCancelled(this.bookingId);
}