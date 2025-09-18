import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/booking_bloc/booking_event.dart';
import 'package:web_flutter/bloc/booking_bloc/booking_state.dart';
import 'package:web_flutter/service/model/booking/booking_service.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/function.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  late BookingService bookingService;

  BookingBloc() : super(BookingInitial()) {
    bookingService = BookingService();

    on<CreateBooking>((event, emit) async {
      emit(BookingLoading());
      try {
        final booking = await bookingService.createBooking(event.reservationReq);
        deboger(['Booking créé avec succès:', booking]);
        emit(BookingCreated(booking));
      } on CustomException catch (e) {
        deboger(['CustomException:', e]);
        emit(BookingError(e.message));
      } on DioException catch (e) {
        deboger(['DioException:', e]);
        emit(BookingError(e.response?.data.toString() ?? "Erreur de création de réservation"));
      } catch (e) {
        deboger(['Exception générale:', e]);
        emit(BookingError("Une erreur est survenue lors de la création de la réservation"));
      }
    });

    on<LoadUserBookings>((event, emit) async {
      emit(BookingLoading());
      try {
        final bookings = await bookingService.getUserBookings();
        emit(BookingLoaded(bookings));
      } on CustomException catch (e) {
        emit(BookingError(e.message));
      } on DioException catch (e) {
        emit(BookingError(e.response?.data.toString() ?? "Erreur de récupération des réservations"));
      } catch (e) {
        emit(BookingError("Une erreur est survenue"));
      }
    });

    on<RefreshBookings>((event, emit) async {
      try {
        final bookings = await bookingService.getUserBookings();
        emit(BookingLoaded(bookings));
      } on CustomException catch (e) {
        emit(BookingError(e.message));
      } on DioException catch (e) {
        emit(BookingError(e.response?.data.toString() ?? "Erreur de rafraîchissement"));
      } catch (e) {
        emit(BookingError("Une erreur est survenue"));
      }
    });

    on<CancelBooking>((event, emit) async {
      emit(BookingLoading());
      try {
        await bookingService.cancelBooking(event.bookingId);
        emit(BookingCancelled(event.bookingId));
        // Recharger la liste des bookings après annulation
        add(LoadUserBookings());
      } on CustomException catch (e) {
        emit(BookingError(e.message));
      } on DioException catch (e) {
        emit(BookingError(e.response?.data.toString() ?? "Erreur d'annulation"));
      } catch (e) {
        emit(BookingError("Une erreur est survenue lors de l'annulation"));
      }
    });
  }
}