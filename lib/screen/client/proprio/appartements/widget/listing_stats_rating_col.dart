import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Colonne « Note moy. » de la `ListingEditStatsCard` — eyebrow + (star +
/// rating mono 22px) + sub `${reviews} avis`.
class ListingStatsRatingCol extends StatelessWidget {
  final double rating;
  final int reviews;

  const ListingStatsRatingCol({
    super.key,
    required this.rating,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
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
              rating.toStringAsFixed(2),
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
          '$reviews avis',
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
