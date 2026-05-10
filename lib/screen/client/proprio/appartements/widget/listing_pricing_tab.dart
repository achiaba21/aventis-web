import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/card/listing_preview.dart';
import 'package:asfar/widget/item/field_row.dart';

/// Tab « Tarifs » du `ProprioListingEditScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListingEdit`
/// (lignes 535-551) : tarif de base hero card + 5 `FieldRow` calculés à la
/// volée depuis `listing.price` (weekend ×1.2, haute saison ×1.4, réduction
/// semaine ×-0.10, réduction mois ×-0.20, frais ménage 8 000 fixe).
class ListingPricingTab extends StatelessWidget {
  final ListingPreview listing;

  const ListingPricingTab({super.key, required this.listing});

  void _stub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition disponible prochainement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _signed(num value) {
    final isNegative = value < 0;
    final abs = value.abs();
    return '${isNegative ? '−' : ''}${FcfaFormatter.full(abs)}';
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = listing.price;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              FieldRow(
                eyebrow: 'TARIF WEEKEND (VEN-SAM)',
                value: _signed((basePrice * 1.2).round()),
                onTap: () => _stub(context),
              ),
              FieldRow(
                eyebrow: 'TARIF HAUTE SAISON',
                value: _signed((basePrice * 1.4).round()),
                onTap: () => _stub(context),
              ),
              FieldRow(
                eyebrow: 'RÉDUCTION SEMAINE (≥7 NUITS)',
                value: _signed(-(basePrice * 0.10).round()),
                onTap: () => _stub(context),
              ),
              FieldRow(
                eyebrow: 'RÉDUCTION MOIS (≥28 NUITS)',
                value: _signed(-(basePrice * 0.20).round()),
                onTap: () => _stub(context),
              ),
              FieldRow(
                eyebrow: 'FRAIS MÉNAGE (PAR SÉJOUR)',
                value: FcfaFormatter.full(8000),
                onTap: () => _stub(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
