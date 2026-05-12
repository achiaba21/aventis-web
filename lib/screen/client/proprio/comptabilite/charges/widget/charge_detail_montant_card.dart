import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card montant + fréquence dans `ChargeDetailScreen`.
class ChargeDetailMontantCard extends StatelessWidget {
  final Charge charge;

  const ChargeDetailMontantCard({super.key, required this.charge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            FcfaFormatter.full((charge.montant ?? 0).round()),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: AppColors.accent,
            )),
          ),
          const SizedBox(height: 4),
          Text(
            charge.frequence.label,
            style: AppTextStyles.small.copyWith(
              fontSize: 13,
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}
