import 'package:flutter/material.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Réductions » du `ProprioListingEditScreen`.
///
/// V9.1 : remplace l'ancien `ListingPricingTab` (tarifs fictifs ×1.2/×1.4)
/// par un branchement réel sur `Appartement.remises.conditions`. Affiche
/// le tarif de base + liste des paliers de remise (seuil `days` + `montant`).
/// EmptyState avec CTA si aucune remise configurée.
///
/// Édition (write) en V9.x — actuellement les taps ouvrent un SnackBar.
class ListingReductionsTab extends StatelessWidget {
  final ListingPreview listing;
  final Appartement? source;

  const ListingReductionsTab({
    super.key,
    required this.listing,
    this.source,
  });

  void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition disponible en V9'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Condition> _sortedConditions() {
    final c = source?.remises?.conditions;
    if (c == null) return const [];
    final list = List<Condition>.from(c)
      ..sort((a, b) => (a.days ?? 0).compareTo(b.days ?? 0));
    return list;
  }

  String _seuilLabel(int? days) {
    if (days == null || days <= 0) return 'PALIER';
    return 'RÉDUCTION ≥ $days NUITS';
  }

  /// Heuristique : montant ≤ 100 → traité comme pourcentage. Au-delà → FCFA
  /// brut. Cohérent avec la convention backend (montant en % des séjours
  /// longs, ou montant fixe pour cas particuliers).
  String _montantLabel(double? montant) {
    if (montant == null) return '—';
    if (montant <= 100) {
      final rounded = montant.round();
      return '−$rounded %';
    }
    return '−${FcfaFormatter.full(montant.round())}';
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = listing.price;
    final conditions = _sortedConditions();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _basePriceCard(basePrice),
        const SizedBox(height: 14),
        if (conditions.isEmpty)
          EmptyState.inline(
            icon: Icons.local_offer_outlined,
            title: 'Aucune réduction configurée',
            body:
                'Ajoutez des paliers (ex : −10 % à partir de 7 nuits) pour attirer les séjours longs.',
            ctaLabel: 'Ajouter un palier',
            onCtaTap: () => _stub(context),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgElev1,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.line, width: 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final c in conditions)
                  FieldRow(
                    eyebrow: _seuilLabel(c.days),
                    value: _montantLabel(c.montant),
                    onTap: () => _stub(context),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _basePriceCard(int basePrice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TARIF DE BASE',
              style: AppTextStyles.eyebrow.copyWith(fontSize: 10)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                FcfaFormatter.full(basePrice),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '/nuit',
                  style: AppTextStyles.small.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
