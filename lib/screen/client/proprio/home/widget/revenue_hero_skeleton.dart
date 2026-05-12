import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Skeleton du `RevenueHeroCard` — affiché pendant le chargement initial
/// des réservations (avant que les agrégations soient calculables).
///
/// Structure visuelle similaire au hero réel (gradient or atténué + halo)
/// avec des placeholders gris bgElev3 pour le titre, le montant et la
/// sparkbar.
class RevenueHeroSkeleton extends StatelessWidget {
  const RevenueHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradientGold,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.25), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _placeholder(width: 120, height: 10),
            const SizedBox(height: 14),
            _placeholder(width: 180, height: 30),
            const SizedBox(height: 12),
            _placeholder(width: 160, height: 12),
            const SizedBox(height: 26),
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < 6; i++) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 18.0 + (i * 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.bgElev3.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgElev3.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
