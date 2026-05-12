import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_timeline_event.dart';

/// Reconstruit la timeline d'une réservation à partir des champs disponibles.
///
/// En V1, seuls `createdAt`, `statut` courant et `motif` sont exploités. Les
/// timestamps précis par transition (`confirmedAt`, `paidAt`, etc.) seront
/// ajoutés quand le backend les exposera — voir
/// `BACKEND_NOTES_RESERVATION_DETAIL.md`.
///
/// Conventions :
/// - L'événement `created` est toujours présent si `createdAt != null`.
/// - L'événement final reflète le `statut` courant.
/// - Pour `refused` et `cancelled`, le `motif` est attaché à l'événement.
class ReservationTimelineBuilder {
  ReservationTimelineBuilder._();

  static List<ReservationTimelineEvent> build(Reservation r) {
    final events = <ReservationTimelineEvent>[];

    if (r.createdAt != null) {
      events.add(ReservationTimelineEvent(
        type: ReservationTimelineEventType.created,
        date: r.createdAt,
      ));
    }

    final statut = r.statut;
    if (statut == null) return events;

    final reached = _statutsReachedBy(statut, isManuelle: r.isManuelle);
    for (final step in reached) {
      events.add(ReservationTimelineEvent(
        type: step,
        date: null,
        motif: _motifFor(step, r),
      ));
    }

    return events;
  }

  static List<ReservationTimelineEventType> _statutsReachedBy(
    ReservationStatus current, {
    bool isManuelle = false,
  }) {
    // Pour une résa manuelle, `confirmee` ≡ argent encaissé. La timeline
    // affiche donc l'étape `paid` implicite à partir de `confirmee`.
    if (isManuelle) {
      switch (current) {
        case ReservationStatus.enAttente:
          return const [];
        case ReservationStatus.confirmee:
          return const [
            ReservationTimelineEventType.confirmed,
            ReservationTimelineEventType.paid,
          ];
        case ReservationStatus.payee:
        case ReservationStatus.finalisee:
        case ReservationStatus.terminee:
          return _plateformeReached(current);
        case ReservationStatus.refusee:
          return const [ReservationTimelineEventType.refused];
        case ReservationStatus.annulee:
          return const [ReservationTimelineEventType.cancelled];
      }
    }
    return _plateformeReached(current);
  }

  static List<ReservationTimelineEventType> _plateformeReached(
    ReservationStatus current,
  ) {
    switch (current) {
      case ReservationStatus.enAttente:
        return const [];
      case ReservationStatus.confirmee:
        return const [ReservationTimelineEventType.confirmed];
      case ReservationStatus.payee:
        return const [
          ReservationTimelineEventType.confirmed,
          ReservationTimelineEventType.paid,
        ];
      case ReservationStatus.finalisee:
        return const [
          ReservationTimelineEventType.confirmed,
          ReservationTimelineEventType.paid,
          ReservationTimelineEventType.finalized,
        ];
      case ReservationStatus.terminee:
        return const [
          ReservationTimelineEventType.confirmed,
          ReservationTimelineEventType.paid,
          ReservationTimelineEventType.finalized,
          ReservationTimelineEventType.terminated,
        ];
      case ReservationStatus.refusee:
        return const [ReservationTimelineEventType.refused];
      case ReservationStatus.annulee:
        return const [ReservationTimelineEventType.cancelled];
    }
  }

  static String? _motifFor(ReservationTimelineEventType type, Reservation r) {
    if (type == ReservationTimelineEventType.refused ||
        type == ReservationTimelineEventType.cancelled) {
      return r.motif;
    }
    return null;
  }

  /// Libellé court (français) d'un type d'événement.
  static String labelOf(ReservationTimelineEventType type) {
    switch (type) {
      case ReservationTimelineEventType.created:
        return 'Créée';
      case ReservationTimelineEventType.confirmed:
        return 'Confirmée';
      case ReservationTimelineEventType.paid:
        return 'Payée';
      case ReservationTimelineEventType.finalized:
        return 'Finalisée';
      case ReservationTimelineEventType.terminated:
        return 'Terminée';
      case ReservationTimelineEventType.refused:
        return 'Refusée';
      case ReservationTimelineEventType.cancelled:
        return 'Annulée';
    }
  }
}
