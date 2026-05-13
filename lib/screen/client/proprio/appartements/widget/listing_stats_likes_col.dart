import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Colonne « Favoris » de la `ListingEditStatsCard` — eyebrow + (cœur +
/// nombre de likes mono 22px) + sub statique.
class ListingStatsLikesCol extends StatelessWidget {
  final int likes;

  const ListingStatsLikesCol({super.key, required this.likes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FAVORIS',
            style: AppTextStyles.eyebrow.copyWith(fontSize: 10)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.favorite, size: 20, color: AppColors.accent),
            const SizedBox(width: 4),
            Text(
              '$likes',
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
          likes <= 1 ? 'ajout favori' : 'ajouts favoris',
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
