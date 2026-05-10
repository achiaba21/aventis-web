import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bloc titre du Detail logement.
///
/// Eyebrow accent (type — "Loft entier"), h1 titre, ligne rating + lieu.
class DetailTitleBlock extends StatelessWidget {
  final String type;
  final String title;
  final double rating;
  final int reviews;
  final String area;
  final String city;

  const DetailTitleBlock({
    super.key,
    required this.type,
    required this.title,
    required this.rating,
    required this.reviews,
    required this.area,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          type.toUpperCase(),
          style: AppTextStyles.eyebrow.copyWith(color: AppColors.accent),
        ),
        const SizedBox(height: 6),
        Text(title, style: AppTextStyles.h1),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 15, color: AppColors.accent),
                const SizedBox(width: 4),
                Text(
                  rating.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(width: 4),
                Text('($reviews avis)', style: AppTextStyles.small),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.place_outlined,
                    size: 14, color: AppColors.text2),
                const SizedBox(width: 4),
                Text('$area, $city', style: AppTextStyles.small),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
