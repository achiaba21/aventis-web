import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Règles » du `ProprioListingEditScreen`.
///
/// Read-only branché sur l'`Appartement.regles` (texte libre saisi par le
/// proprio à la création). Les 6 sous-règles structurées du proto
/// (arrivée/départ/animaux/fêtes/fumeurs/caution) ne sont pas portées par
/// le model métier — affichage simple du texte libre + EmptyState si vide.
/// Édition (write) en V9.
class ListingRulesTab extends StatelessWidget {
  final Appartement? source;

  const ListingRulesTab({super.key, this.source});

  void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition disponible en V9'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final regles = source?.regles?.trim();
    if (regles == null || regles.isEmpty) {
      return EmptyState.inline(
        icon: Icons.rule_outlined,
        title: 'Aucune règle définie',
        body: 'Précisez les règles de votre logement (arrivée, animaux, fêtes…).',
        ctaLabel: 'Ajouter',
        onCtaTap: () => _stub(context),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          FieldRow(
            eyebrow: 'RÈGLES DU LOGEMENT',
            value: regles,
            onTap: () => _stub(context),
          ),
        ],
      ),
    );
  }
}
