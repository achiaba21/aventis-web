import 'package:asfar/widget/card/listing_preview.dart';

/// Performance d'un bien — section « Performance par bien »
/// (`ProprioFinancesScreen`).
///
/// Reproduit le mock du proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 274-303). Réutilise [ListingPreview] (V5) pour la référence du
/// logement.
class PropertyPerf {
  final ListingPreview listing;

  /// Taux d'occupation entre 0 et 1.
  final double occupancyRate;

  /// Revenus mensuels en FCFA.
  final int monthlyRevenue;

  /// Évolution % vs mois précédent (positif = success).
  final int deltaPercent;

  const PropertyPerf({
    required this.listing,
    required this.occupancyRate,
    required this.monthlyRevenue,
    required this.deltaPercent,
  });
}
