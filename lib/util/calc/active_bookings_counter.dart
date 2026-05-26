import 'package:asfar/model/reservation/reservation.dart';

/// Compte les réservations « actives aujourd'hui » d'un proprio.
///
/// Sémantique (cf. business-spec §4.6) :
/// - La réservation est confirmée OU en cours de séjour (`CONFIRMER`, `PAYER`,
///   `FINALISER`).
/// - Son intervalle `[debut, fin[` contient la date courante (check-in fait,
///   check-out pas encore).
///
/// Utilisé par la card dashboard « Calendrier & bookings » qui affiche
/// « N séjours en cours ».
class ActiveBookingsCounter {
  ActiveBookingsCounter._();

  /// Statuts considérés comme « actifs » (check-in possible / fait).
  static const Set<ReservationStatus> _activeStatuses = {
    ReservationStatus.confirmee,
    ReservationStatus.payee,
    ReservationStatus.finalisee,
  };

  /// Compte les réservations dont `[debut, fin[` contient [now] et dont le
  /// statut est dans [_activeStatuses].
  ///
  /// [now] injectable pour les tests (par défaut : `DateTime.now()`).
  static int activeToday(
    List<Reservation> reservations, {
    DateTime? now,
  }) {
    final ref = _dateOnly(now ?? DateTime.now());
    var count = 0;
    for (final r in reservations) {
      if (r.statut == null || !_activeStatuses.contains(r.statut)) continue;
      if (r.debut == null || r.fin == null) continue;
      final start = _dateOnly(r.debut!);
      final end = _dateOnly(r.fin!);
      // [start, end[ contient ref → start <= ref < end
      if (!ref.isBefore(start) && ref.isBefore(end)) {
        count++;
      }
    }
    return count;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
