import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Mini KPI affiché dans le body d'une `ListingFullCard` — label eyebrow
/// + valeur mono.
///
/// Si `withStar` est true, affiche une étoile or à gauche de la valeur
/// (utilisé pour la note).
class ListingFullCardKpi extends StatelessWidget {
  final String label;
  final String value;
  final bool withStar;

  const ListingFullCardKpi({
    super.key,
    required this.label,
    required this.value,
    this.withStar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.eyebrow.copyWith(fontSize: 9),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (withStar) ...[
              const Icon(Icons.star, size: 12, color: AppColors.accent),
              const SizedBox(width: 3),
            ],
            Text(
              value,
              style: AppTextStyles.mono(const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              )),
            ),
          ],
        ),
      ],
    );
  }
}
