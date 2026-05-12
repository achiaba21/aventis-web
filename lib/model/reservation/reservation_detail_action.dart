/// Actions exposables sur la page de détail d'une réservation.
///
/// La matrice rôle × statut × type est résolue par
/// `ReservationActionsResolver.actionsFor(...)`.
enum ReservationDetailAction {
  /// Annuler la réservation (locataire ou proprio sur manuelle).
  cancel,

  /// Payer la réservation (locataire, statut confirmée).
  pay,

  /// Confirmer la réservation (proprio, statut en attente).
  confirm,

  /// Refuser la réservation (proprio, statut en attente).
  refuse,

  /// Afficher le QR code (locataire, statut ≥ payée).
  viewQr,

  /// Scanner le QR du locataire (proprio, statut payée → finalisation).
  scanQr,

  /// Éditer une réservation manuelle (proprio, statut < payée).
  edit,

  /// Contacter la contrepartie (toujours disponible).
  contact,
}
