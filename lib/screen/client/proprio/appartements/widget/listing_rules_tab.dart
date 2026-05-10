import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Règles » du `ProprioListingEditScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListingEdit`
/// (lignes 553-564) : 6 `FieldRow` constantes regroupées dans une Container
/// card unique (cohérence pattern V5 `LocataireReserveScreen`).
class ListingRulesTab extends StatelessWidget {
  const ListingRulesTab({super.key});

  void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition disponible prochainement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              eyebrow: 'ARRIVÉE',
              value: 'À partir de 14h',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'DÉPART',
              value: 'Avant 11h',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'ANIMAUX',
              value: 'Non autorisés',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'FÊTES',
              value: 'Non autorisées',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'FUMEURS',
              value: 'Non autorisé',
              onTap: () => _stub(context)),
          FieldRow(
              eyebrow: 'CAUTION',
              value: '50 000 FCFA',
              onTap: () => _stub(context)),
        ],
      ),
    );
  }
}
