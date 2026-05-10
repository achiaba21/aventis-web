import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/screen/client/proprio/home/widget/sparkbar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Hero card « Revenus du mois » du Dashboard propriétaire.
///
/// Reproduit fidèlement le proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 33-76) : gradient `heroGradientGold` 3 stops, halo radial accent
/// top-right, montant 32px mono bold, badge delta success « ↑ +20% »,
/// label « vs. octobre · 1.58 M FCFA », sparkbar inline 6 mois.
class RevenueHeroCard extends StatelessWidget {
  final int amount;
  final int deltaPercent;
  final int previousAmount;
  final List<MonthlyRevenue> last6Months;

  const RevenueHeroCard({
    super.key,
    required this.amount,
    required this.deltaPercent,
    required this.previousAmount,
    required this.last6Months,
  });

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
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REVENUS DU MOIS',
                  style: AppTextStyles.eyebrow.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  FcfaFormatter.compact(amount),
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                    color: Colors.white,
                  )),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    BadgeStatus(
                      text: '↑ +$deltaPercent%',
                      tone: BadgeTone.success,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'vs. octobre · ${FcfaFormatter.compact(previousAmount)}',
                        style: AppTextStyles.small.copyWith(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Sparkbar(months: last6Months),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
