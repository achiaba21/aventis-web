import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/screen/client/proprio/home/widget/revenue_hero_skeleton.dart';
import 'package:asfar/screen/client/proprio/home/widget/sparkbar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/finance/delta_badge_row.dart';
import 'package:asfar/widget/finance/period_nav_eyebrow.dart';
import 'package:asfar/widget/finance/pipeline_trace_line.dart';

/// Hero card « Revenus » du Dashboard propriétaire.
///
/// **Stateless** — l'écran parent (Dashboard) tient le state
/// `selectedMonth` + `last6Months` pré-calculés via `MonthlyRevenueCalculator`.
/// Cohérent avec `BeneficeNetHeroCard` côté Finances.
///
/// Composé d'atomes réutilisables (`PeriodNavEyebrow`, `DeltaBadgeRow`,
/// `PipelineTraceLine`, `Sparkbar`).
class RevenueHeroCard extends StatelessWidget {
  final int amount;
  final int previousAmount;
  final int deltaPercent;
  final int pipelineAmount;
  final int average3Months;
  final List<MonthlyRevenue> last6Months;
  final DateTime selectedMonth;
  final String eyebrowLabel;
  final String previousMonthLabel;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<MonthlyRevenue> onSparkbarTap;
  final bool isLoading;

  const RevenueHeroCard({
    super.key,
    required this.amount,
    required this.previousAmount,
    required this.deltaPercent,
    required this.pipelineAmount,
    required this.average3Months,
    required this.last6Months,
    required this.selectedMonth,
    required this.eyebrowLabel,
    required this.previousMonthLabel,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
    required this.onSparkbarTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && last6Months.isEmpty) {
      return const RevenueHeroSkeleton();
    }
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
                PeriodNavEyebrow(
                  label: eyebrowLabel,
                  canGoPrev: canGoPrev,
                  canGoNext: canGoNext,
                  onPrev: onPrev,
                  onNext: onNext,
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
                DeltaBadgeRow(
                  deltaPercent: deltaPercent,
                  previousAmount: previousAmount,
                  previousLabel: previousMonthLabel,
                  textColor: Colors.white.withValues(alpha: 0.6),
                ),
                if (pipelineAmount > 0) ...[
                  const SizedBox(height: 4),
                  PipelineTraceLine(
                    amount: pipelineAmount,
                    textAlpha: 0.75,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Moy. 3 mois · ${FcfaFormatter.compact(average3Months)}',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 18),
                Sparkbar(
                  months: last6Months,
                  selectedMonth: selectedMonth,
                  onBarTap: onSparkbarTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
