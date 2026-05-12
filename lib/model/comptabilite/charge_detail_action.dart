/// Actions exposables sur la page de détail d'une charge.
enum ChargeDetailAction {
  /// Marquer payée (charge actuellement non payée).
  markPaid,

  /// Marquer impayée (charge actuellement payée — annulation).
  markUnpaid,

  /// Éditer la charge (push ChargeFormScreen.edit).
  edit,

  /// Supprimer la charge (confirmation puis DELETE API).
  delete,
}
