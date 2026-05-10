/// Un point du line chart « Projection 3 mois » du `ProprioFinancesScreen`.
///
/// Reproduit le mock SVG du proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 317-345). 7 points Sept→Mars.
///
/// [isProjection] : `false` = passé (trait solid), `true` = futur (trait dashed).
/// [isCurrent] : `true` pour le mois courant (Nov) — marker accent or +
/// vertical line séparateur passé/futur.
class ProjectionPoint {
  final String monthShort;
  final int amount;
  final bool isProjection;
  final bool isCurrent;

  const ProjectionPoint({
    required this.monthShort,
    required this.amount,
    required this.isProjection,
    this.isCurrent = false,
  });
}
