/// Type d'une ligne du compte de résultat (`PnLCard`).
enum PnLKind {
  /// Header de catégorie (ex: « + Revenus », « − Charges »). Affiché en bold
  /// avec couleur sémantique.
  categoryHeader,

  /// Ligne détaillée d'une catégorie (ex: « Locations brutes (42 nuits) »).
  /// Affichée indentée en `text-2`.
  categoryDetail,

  /// Ligne « Bénéfice net » — accent or 18px bold.
  netIncome,

  /// Ligne « Marge nette » — small 11px success.
  netMargin,
}

/// Une ligne du compte de résultat — `ProprioFinancesScreen::PnLCard`.
///
/// Reproduit la structure du proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 222-271). Les marges sont stockées en pourcentage (ex: `62`).
class PnLEntry {
  final String label;
  final int amount;
  final PnLKind kind;

  /// Pour les `categoryHeader`, indique si c'est un revenu (`true`, success vert)
  /// ou une charge (`false`, danger rouge).
  final bool isRevenue;

  const PnLEntry({
    required this.label,
    required this.amount,
    required this.kind,
    this.isRevenue = true,
  });
}
