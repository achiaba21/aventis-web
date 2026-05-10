import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Colonne « Occupation » de la `ListingEditStatsCard` — eyebrow + valeur
/// mono 22px + barre progress 4px accent.
class ListingStatsOccupancyCol extends StatelessWidget {
  final double occupancyRate;

  const ListingStatsOccupancyCol({super.key, required this.occupancyRate});

  @override
  Widget build(BuildContext context) {
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
                    widthFactor: occupancyRate.clamp(0.0, 1.0),
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
}
