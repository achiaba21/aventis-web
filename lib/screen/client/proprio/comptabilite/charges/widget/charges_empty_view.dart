import 'package:flutter/material.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// État vide de l'écran liste des charges.
///
/// Adapte le message selon que l'utilisateur a des filtres actifs ou non,
/// et selon qu'il a des appartements ou non (cas extrême CA1).
class ChargesEmptyView extends StatelessWidget {
  final bool hasFilters;
  final bool hasAppartements;
  final VoidCallback? onCreateCharge;
  final VoidCallback? onCreateAppartement;
  final VoidCallback? onClearFilters;

  const ChargesEmptyView({
    super.key,
    required this.hasFilters,
    required this.hasAppartements,
    this.onCreateCharge,
    this.onCreateAppartement,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasAppartements) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
        child: EmptyState.hero(
          icon: Icons.home_outlined,
          title: 'Aucun appartement',
          body:
              'Créez d\'abord un appartement pour pouvoir ajouter des charges.',
          ctaLabel: 'Créer un appartement',
          onCtaTap: onCreateAppartement,
        ),
      );
    }
    if (hasFilters) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
        child: EmptyState.hero(
          icon: Icons.filter_alt_off_outlined,
          title: 'Aucune charge ne correspond',
          body: 'Essayez de modifier vos filtres pour voir plus de charges.',
          ctaLabel: 'Réinitialiser les filtres',
          onCtaTap: onClearFilters,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
      child: EmptyState.hero(
        icon: Icons.receipt_long_outlined,
        title: 'Aucune charge enregistrée',
        body:
            'Ajoutez vos charges (loyer, électricité, eau…) pour un suivi financier complet.',
        ctaLabel: 'Ajouter une charge',
        onCtaTap: onCreateCharge,
      ),
    );
  }
}
