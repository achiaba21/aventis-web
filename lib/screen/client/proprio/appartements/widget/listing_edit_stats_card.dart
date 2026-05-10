import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Card stats compacte du `ProprioListingEditScreen` — affichée juste après
/// le Hero photo.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListingEdit`
/// (lignes 481-502) : Row 2 cols séparée par un `Container 1×_` line.
/// Col 1 = eyebrow Occupation + valeur mono 22px + barre progress 4px accent.
/// Col 2 = eyebrow Note moy. + Row(star + rating mono 22px) + sub `${reviews} avis`.
class ListingEditStatsCard extends StatelessWidget {
  final ListingPreview listing;
  final double occupancyRate;

  const ListingEditStatsCard({
    super.key,
    required this.listing,
    required this.occupancyRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(child: _occupancyCol()),
            Container(width: 1, color: AppColors.line),
            const SizedBox(width: 16),
            Expanded(child: _ratingCol()),
          ],
        ),
      ),
    );
  }

  Widget _occupancyCol() {
    final occupancyPct = (occupancyRate * 100).round();
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('OCCUPATION',
              style: AppTextStyles.eyebrow.copyWith(fontSize: 10)),
          const SizedBox(height: 4),
          Text(
            '$occupancyPct%',
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            )),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 4,
              child: Stack(
                children: [
                  Container(color: AppColors.bgElev3),
                  FractionallySizedBox(
                    widthFactor: occupancyRate,
                    child: Container(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NOTE MOY.',
            style: AppTextStyles.eyebrow.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              listing.rating.toStringAsFixed(2),
              style: AppTextStyles.mono(const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              )),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${listing.reviews} avis',
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
