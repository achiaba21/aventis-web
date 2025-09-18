import 'package:web_flutter/model/request/reservation_req.dart';

abstract class BookingEvent {}

class CreateBooking extends BookingEvent {
  final ReservationReq reservationReq;

  CreateBooking(this.reservationReq);
}

class LoadUserBookings extends BookingEvent {}

class RefreshBookings extends BookingEvent {}

class CancelBooking extends BookingEvent {
  final int bookingId;

  CancelBooking(this.bookingId);
}