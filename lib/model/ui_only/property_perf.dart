import 'package:asfar/model/residence/appart.dart';

/// Performance d'un bien — section « Performance par bien »
/// (`ProprioFinancesScreen`).
///
/// Agrégation pure pour la section dashboard : référence l'appartement
/// source (modèle métier) + métriques calculées (occupation, revenu, delta).
class PropertyPerf {
  final Appartement appartement;

  /// Taux d'occupation entre 0 et 1.
  final double occupancyRate;

  /// Revenus mensuels en FCFA.
  final int monthlyRevenue;

  /// Évolution % vs mois précédent (positif = success).
  final int deltaPercent;

  const PropertyPerf({
    required this.appartement,
    required this.occupancyRate,
    required this.monthlyRevenue,
    required this.deltaPercent,
  });
}
