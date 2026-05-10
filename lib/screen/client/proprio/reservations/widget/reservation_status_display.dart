import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Mapping `ReservationStatus` → libellé court FR + ton du `BadgeStatus`.
///
/// Helper dédié pour respecter la règle 3 du projet (helpers extraits) — évite
/// la dispersion de la logique dans `ProprioReservationRow`,
/// `ProprioReservationsScreen`, etc.
class ReservationStatusDisplay {
  ReservationStatusDisplay._();

  static String labelOf(ReservationStatus? status) {
    switch (status) {
      case ReservationStatus.enAttente:
        return 'En attente';
      case ReservationStatus.confirmee:
        return 'Confirmée';
      case ReservationStatus.payee:
        return 'Payée';
      case ReservationStatus.finalisee:
        return 'Finalisée';
      case ReservationStatus.terminee:
        return 'Terminée';
      case ReservationStatus.refusee:
        return 'Refusée';
      case ReservationStatus.annulee:
        return 'Annulée';
      case null:
        return '—';
    }
  }

  static BadgeTone toneOf(ReservationStatus? status) {
    switch (status) {
      case ReservationStatus.enAttente:
        return BadgeTone.warn;
      case ReservationStatus.confirmee:
      case ReservationStatus.payee:
        return BadgeTone.success;
      case ReservationStatus.finalisee:
      case ReservationStatus.terminee:
        return BadgeTone.neutral;
      case ReservationStatus.refusee:
      case ReservationStatus.annulee:
        return BadgeTone.danger;
      case null:
        return BadgeTone.neutral;
    }
  }
}
