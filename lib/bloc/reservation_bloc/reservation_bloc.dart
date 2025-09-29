import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/reservation_bloc/reservation_event.dart';
import 'package:web_flutter/bloc/reservation_bloc/reservation_state.dart';
import 'package:web_flutter/service/model/booking/reservation_service.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/function.dart';

class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  late ReservationService reservationService;

  ReservationBloc() : super(ReservationInitial()) {
    reservationService = ReservationService();

    on<CreateReservation>((event, emit) async {
      emit(ReservationLoading());
      try {
        final reservation = await reservationService.createReservation(event.reservationReq);
        deboger(['Réservation créée avec succès:', reservation]);
        emit(ReservationCreated(reservation));
      } on CustomException catch (e) {
        deboger(['CustomException:', e]);
        emit(ReservationError(e.message));
      } on DioException catch (e) {
        deboger(['DioException:', e]);
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de création de réservation"));
      } catch (e) {
        deboger(['Exception générale:', e]);
        emit(ReservationError("Une erreur est survenue lors de la création de la réservation"));
      }
    });

    on<LoadUserReservations>((event, emit) async {
      emit(ReservationLoading());
      try {
        final reservations = await reservationService.getUserReservations();
        emit(ReservationLoaded(reservations));
      } on CustomException catch (e) {
        emit(ReservationError(e.message));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de récupération des réservations"));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue"));
      }
    });

    on<RefreshReservations>((event, emit) async {
      try {
        final reservations = await reservationService.getUserReservations();
        emit(ReservationLoaded(reservations));
      } on CustomException catch (e) {
        emit(ReservationError(e.message));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de rafraîchissement"));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue"));
      }
    });

    on<CancelReservation>((event, emit) async {
      emit(ReservationLoading());
      try {
        await reservationService.cancelReservation(event.reservationId);
        emit(ReservationCancelled(event.reservationId));
        // Recharger la liste des réservations après annulation
        add(LoadUserReservations());
      } on CustomException catch (e) {
        emit(ReservationError(e.message));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur d'annulation"));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue lors de l'annulation"));
      }
    });
  }
}