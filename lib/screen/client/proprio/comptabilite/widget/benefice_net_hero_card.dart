import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/finance_period.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/finance/delta_badge_row.dart';
import 'package:asfar/widget/finance/period_nav_eyebrow.dart';
import 'package:asfar/widget/finance/pipeline_trace_line.dart';

/// Card hero du Bénéfice net — `ProprioFinancesScreen`.
///
/// Composé d'atomes réutilisables (`PeriodNavEyebrow`, `DeltaBadgeRow`,
/// `PipelineTraceLine`). Le caller (screen) gère le state période/année/index
/// et passe les agrégats pré-calculés.
class BeneficeNetHeroCard extends StatelessWidget {
  final int amount;
  final int previousAmount;
  final int deltaPercent;
  final int pipelineAmount;
  final FinancePeriod period;
  final int year;
  final int index;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const BeneficeNetHeroCard({
    super.key,
    required this.amount,
    required this.previousAmount,
    required this.deltaPercent,
    required this.pipelineAmount,
    required this.period,
    required this.year,
    required this.index,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final eyebrow =
        'BÉNÉFICE NET · ${period.periodLabel(year, index).toUpperCase()}';
    final prevLabel =
        period.previousPeriodLongLabel(year, index).toLowerCase();

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
          PeriodNavEyebrow(
            label: eyebrow,
            canGoPrev: canGoPrev,
            canGoNext: canGoNext,
            onPrev: onPrev,
            onNext: onNext,
            fontSize: 10,
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
          DeltaBadgeRow(
            deltaPercent: deltaPercent,
            previousAmount: previousAmount,
            previousLabel: prevLabel,
          ),
          if (pipelineAmount > 0) ...[
            const SizedBox(height: 4),
            PipelineTraceLine(amount: pipelineAmount),
          ],
        ],
      ),
    );
  }
}
