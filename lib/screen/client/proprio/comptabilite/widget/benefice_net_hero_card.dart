import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Card hero du Bénéfice net — `ProprioFinancesScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 211-220) : card simple `bgElev1` (pas de gradient — différencie
/// du `RevenueHeroCard` du Dashboard) + eyebrow + montant 30px mono bold +
/// badge delta success.
class BeneficeNetHeroCard extends StatelessWidget {
  final int amount;
  final int deltaPercent;
  final String periodLabel;

  const BeneficeNetHeroCard({
    super.key,
    required this.amount,
    required this.deltaPercent,
    this.periodLabel = 'novembre',
  });

  @override
  Widget build(BuildContext context) {
    final positive = deltaPercent >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BÉNÉFICE NET · ${periodLabel.toUpperCase()}',
            style: AppTextStyles.eyebrow.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            FcfaFormatter.full(amount),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: AppColors.text,
            )),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              BadgeStatus(
                text: '${positive ? '↑' : '↓'} ${deltaPercent.abs()}%',
                tone: positive ? BadgeTone.success : BadgeTone.danger,
              ),
              const SizedBox(width: 6),
              Text(
                'vs. mois précédent',
                style: AppTextStyles.small.copyWith(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
