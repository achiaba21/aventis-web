/// Actions exposables sur la page de détail d'une charge.
///
/// Sémantique post-2026-05-13 : chaque charge = un paiement déjà enregistré,
/// donc les actions `markPaid` / `markUnpaid` ont été retirées.
enum ChargeDetailAction {
  /// Éditer la charge (push ChargeFormScreen.edit).
  edit,

  /// Supprimer la charge (confirmation puis DELETE API).
  delete,
}
