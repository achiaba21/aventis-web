import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Card résumé compact d'un listing — utilisée dans le tunnel Reserve.
///
/// Consomme directement [Appartement]. Image 80×80 + titre + lieu + rating.
class ListingSummaryCard extends StatelessWidget {
  final Appartement appartement;

  const ListingSummaryCard({super.key, required this.appartement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: ImgPh(tone: appartement.tone, radius: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appartement.titleSafe,
                  style: AppTextStyles.h3.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${appartement.areaName} · ${appartement.cityName}',
                  style: AppTextStyles.small.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text(
                      appartement.rating.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${appartement.reviewsCount})',
                      style: AppTextStyles.small.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
