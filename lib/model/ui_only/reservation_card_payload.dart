/// Payload minimal d'un message `MessageKind.reservationCard` — V9.2.
///
/// Aligné sur le brief backend 2026-05-11 : le contenu du message émis par
/// le serveur est `[ASFAR_CARD:reservation]{"ref":"ASF-XXX"}`. Le payload
/// ne porte que la **référence** ; le détail (titre appart, dates, prix)
/// est récupéré lazy via `ReservationService.getByReference()` dans le
/// `ReservationMessageCard` au mount.
class ReservationCardPayload {
  final String reference;

  const ReservationCardPayload({required this.reference});
}
