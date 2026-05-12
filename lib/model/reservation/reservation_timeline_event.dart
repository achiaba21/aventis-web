/// Type d'événement dans la timeline d'une réservation.
enum ReservationTimelineEventType {
  created,
  confirmed,
  paid,
  finalized,
  terminated,
  refused,
  cancelled,
}

/// Entrée de la timeline d'une réservation — modèle UI-only.
///
/// Reconstruite côté Flutter par `ReservationTimelineBuilder` à partir des
/// champs disponibles sur `Reservation` (createdAt, statut, motif). Les
/// timestamps précis (`confirmedAt`, `paidAt`, etc.) seront ajoutés quand
/// le backend les exposera — voir `BACKEND_NOTES_RESERVATION_DETAIL.md`.
class ReservationTimelineEvent {
  final ReservationTimelineEventType type;
  final DateTime? date;
  final String? motif;

  const ReservationTimelineEvent({
    required this.type,
    this.date,
    this.motif,
  });

  /// Indique si cet événement représente une issue défavorable (refus/annulation).
  bool get isNegative =>
      type == ReservationTimelineEventType.refused ||
      type == ReservationTimelineEventType.cancelled;
}
