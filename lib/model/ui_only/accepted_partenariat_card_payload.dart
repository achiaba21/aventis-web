/// Payload minimal d'un message `MessageKind.acceptedPartenariatCard` — V9.2.
///
/// Aligné sur le brief backend 2026-05-11 : le contenu du message émis par
/// le serveur est `[ASFAR_CARD:partenariat]{"id":12}`. Le payload ne porte
/// que l'**id de la demande** ; le détail (nom proprio/démarcheur,
/// téléphones, statut, dates) est récupéré lazy via
/// `PartenariatService.getDemandeById()` dans
/// `AcceptedPartenariatMessageCard` au mount.
///
/// Renommé de `AcceptedReferralCardPayload` côté V9.2 pour aligner le
/// nommage backend (`partenariat` au lieu de `referral`).
class AcceptedPartenariatCardPayload {
  final int demandeId;

  const AcceptedPartenariatCardPayload({required this.demandeId});
}
