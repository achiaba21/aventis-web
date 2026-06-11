import 'package:asfar/model/reservation/code_reservation.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/request/reservation_req.dart';

/// État de base pour les réservations
///
/// Pattern "keep last known data" : conserve les réservations connues
/// même pendant les transitions d'état pour éviter les flashs UI
abstract class ReservationState {
  final ReservationReq? currentReq;

  /// Liste des dernières réservations connues (persistée entre les états)
  final List<Reservation> reservations;

  ReservationState({this.currentReq, this.reservations = const []});
}

class ReservationInitial extends ReservationState {
  ReservationInitial({super.currentReq, super.reservations});
}

class ReservationLoading extends ReservationState {
  ReservationLoading({super.currentReq, super.reservations});
}

class ReservationCreated extends ReservationState {
  final Reservation reservation;

  ReservationCreated(this.reservation, {super.currentReq, super.reservations});
}

/// État émis après création d'une réservation manuelle
class ReservationManuelleCreated extends ReservationState {
  final Reservation reservation;

  ReservationManuelleCreated(this.reservation, {super.currentReq, super.reservations});
}

class ReservationLoaded extends ReservationState {
  /// Pagination (PERF-02) — neutres tant que LoadMoreReservations n'est pas
  /// émis. Support sans câblage UI : les écrans actuels ne paginent pas.
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final int currentPage;

  ReservationLoaded(
    List<Reservation> reservations, {
    super.currentReq,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.currentPage = 0,
  }) : super(reservations: reservations);

  ReservationLoaded copyWith({
    List<Reservation>? reservations,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    int? currentPage,
  }) {
    return ReservationLoaded(
      reservations ?? this.reservations,
      currentReq: currentReq,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class ReservationError extends ReservationState {
  final String message;

  ReservationError(this.message, {super.currentReq, super.reservations});
}

class ReservationCancelled extends ReservationState {
  final String reference;

  ReservationCancelled(this.reference, {super.currentReq, super.reservations});
}

class ReservationConfirmed extends ReservationState {
  final String reference;

  ReservationConfirmed(this.reference, {super.currentReq, super.reservations});
}

class ReservationRefused extends ReservationState {
  final String reference;

  ReservationRefused(this.reference, {super.currentReq, super.reservations});
}

class ReservationPaid extends ReservationState {
  final String reference;

  ReservationPaid(this.reference, {super.currentReq, super.reservations});
}

class ReservationCodeLoaded extends ReservationState {
  final CodeReservation code;

  ReservationCodeLoaded(this.code, {super.currentReq, super.reservations});
}

class ReservationFinalized extends ReservationState {
  final String secretKey;

  ReservationFinalized(this.secretKey, {super.currentReq, super.reservations});
}

class ReservationReqUpdated extends ReservationState {
  ReservationReqUpdated(ReservationReq? req, {super.reservations})
      : super(currentReq: req);
}