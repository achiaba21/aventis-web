/// Statut visuel dérivé d'une charge — calculé côté UI à partir des champs
/// `estPaye`, `dateEcheance` et de la date courante.
///
/// Différent de `estPaye` (bool brut) : ajoute les nuances "en retard" et
/// "échéance proche" utilisées par les alertes et les filtres UI.
enum ChargeStatut {
  /// Charge déjà réglée (`estPaye == true`).
  payee,

  /// Charge non payée dont l'échéance est passée.
  enRetard,

  /// Charge non payée dont l'échéance est dans les 7 prochains jours.
  echeanceProche,

  /// Charge non payée, échéance dans le futur (> 7 jours) ou non définie.
  impayee,
}
