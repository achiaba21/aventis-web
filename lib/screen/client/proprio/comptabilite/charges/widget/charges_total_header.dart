import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Bandeau récapitulatif au-dessus de la liste des charges : nombre de charges
/// (filtrées) + total monétaire. Recalculé par l'écran selon les filtres
/// actifs.
class ChargesTotalHeader extends StatelessWidget {
  final int count;
  final int total;

  const ChargesTotalHeader({
    super.key,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final label = count > 1 ? '$count charges' : '$count charge';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.small.copyWith(color: AppColors.text2),
          ),
          Text(
            FcfaFormatter.full(total),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            )),
          ),
        ],
      ),
    );
  }
}
