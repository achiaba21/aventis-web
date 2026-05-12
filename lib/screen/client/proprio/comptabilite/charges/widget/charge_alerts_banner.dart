import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Banner alertes en tête de `ChargesListScreen` — affiché si retards.
///
/// Fond `errorLight` (danger 14%) + border danger 30% + icon + texte multi-ligne.
class ChargeAlertsBanner extends StatelessWidget {
  final int retardCount;
  final int retardAmount;

  const ChargeAlertsBanner({
    super.key,
    required this.retardCount,
    required this.retardAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        border: Border.all(
          color: AppColors.danger.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$retardCount charge${retardCount > 1 ? 's' : ''} en retard',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${FcfaFormatter.full(retardAmount)} à régler',
                  style: AppTextStyles.mono(AppTextStyles.small.copyWith(
                    fontSize: 12,
                    color: AppColors.text2,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
