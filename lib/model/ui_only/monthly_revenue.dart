/// Une barre du `Sparkbar` 6 mois — Dashboard propriétaire.
///
/// Agrégation pure de présentation : un mois donné + le montant encaissé
/// (résa payee/finalisee/terminee) + le montant engagé/pipeline (résa
/// confirmee non encore payées). La sparkbar empile les 2 segments :
/// plein or pour l'encaissé + translucide or pour le pipeline.
class MonthlyRevenue {
  final DateTime month;
  final String monthShort;

  /// Encaissé réel : statuts payee + finalisee + terminee (frais déduits).
  final int amount;

  /// Engagé en attente de paiement : statut confirmee (frais déduits).
  final int pipeline;

  const MonthlyRevenue({
    required this.month,
    required this.monthShort,
    required this.amount,
    this.pipeline = 0,
  });

  int get total => amount + pipeline;

  bool sameMonthAs(DateTime other) =>
      other.year == month.year && other.month == month.month;
}
