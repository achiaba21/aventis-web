import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/home/widget/revenue_hero_skeleton.dart';
import 'package:asfar/screen/client/proprio/home/widget/sparkbar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/monthly_revenue_calculator.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Hero card « Revenus » du Dashboard propriétaire.
///
/// Consomme directement `List<Reservation>` et calcule en interne via
/// `MonthlyRevenueCalculator`. Navigation mois/année non-invasive via
/// chevrons ‹ › collés à l'eyebrow + sparkbar tappable.
///
/// Affiche : gradient `heroGradientGold` 3 stops, halo radial accent
/// top-right, montant 32px mono bold, badge delta signé success/danger/
/// neutral, label « vs. {mois précédent} · X FCFA », moyenne 3 mois +
/// sparkbar 6 mois.
class RevenueHeroCard extends StatefulWidget {
  final List<Reservation> reservations;
  final bool isLoading;

  const RevenueHeroCard({
    super.key,
    required this.reservations,
    this.isLoading = false,
  });

  @override
  State<RevenueHeroCard> createState() => _RevenueHeroCardState();
}

class _RevenueHeroCardState extends State<RevenueHeroCard> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = MonthlyRevenueCalculator.normalize(DateTime.now());
  }

  bool get _isCurrentMonth {
    final now = MonthlyRevenueCalculator.normalize(DateTime.now());
    return _selectedMonth.year == now.year &&
        _selectedMonth.month == now.month;
  }

  void _goPrev() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _goNext() {
    if (_isCurrentMonth) return;
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  void _selectBarMonth(DateTime month) {
    setState(() => _selectedMonth = MonthlyRevenueCalculator.normalize(month));
  }

  String _eyebrowLabel() {
    final short = MonthlyRevenueCalculator.shortLabel(_selectedMonth);
    return 'REVENUS · ${short.toUpperCase()}. ${_selectedMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.reservations.isEmpty) {
      return const RevenueHeroSkeleton();
    }

    final amount = MonthlyRevenueCalculator.revenueFor(
      widget.reservations,
      targetMonth: _selectedMonth,
    );
    final previousAmount = MonthlyRevenueCalculator.previousRevenue(
      widget.reservations,
      targetMonth: _selectedMonth,
    );
    final deltaPercent = MonthlyRevenueCalculator.deltaPercent(
      widget.reservations,
      targetMonth: _selectedMonth,
    );
    final pipeline = MonthlyRevenueCalculator.pipelineFor(
      widget.reservations,
      targetMonth: _selectedMonth,
    );
    final avg3 = MonthlyRevenueCalculator.average3MonthsEnding(
      widget.reservations,
      targetMonth: _selectedMonth,
    );
    final last6 = MonthlyRevenueCalculator.last6Months(
      widget.reservations,
      targetMonth: _selectedMonth,
    );
    final prevMonth = MonthlyRevenueCalculator.previousMonth(
      targetMonth: _selectedMonth,
    );
    final prevLabel = MonthlyRevenueCalculator.fullLabel(prevMonth);

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
                _EyebrowRow(
                  label: _eyebrowLabel(),
                  canGoPrev: true,
                  canGoNext: !_isCurrentMonth,
                  onPrev: _goPrev,
                  onNext: _goNext,
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
                _DeltaRow(
                  deltaPercent: deltaPercent,
                  previousAmount: previousAmount,
                  previousMonthLabel: prevLabel,
                ),
                if (pipeline > 0) ...[
                  const SizedBox(height: 4),
                  _PipelineLine(amount: pipeline),
                ],
                const SizedBox(height: 4),
                Text(
                  'Moy. 3 mois · ${FcfaFormatter.compact(avg3)}',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 18),
                Sparkbar(
                  months: last6,
                  selectedMonth: _selectedMonth,
                  onBarTap: (m) => _selectBarMonth(m.month),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Eyebrow interactive avec chevrons ‹ › à gauche et à droite du libellé.
class _EyebrowRow extends StatelessWidget {
  final String label;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _EyebrowRow({
    required this.label,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChevronButton(
          icon: Icons.chevron_left,
          enabled: canGoPrev,
          onTap: onPrev,
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.eyebrow.copyWith(
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 2),
        _ChevronButton(
          icon: Icons.chevron_right,
          enabled: canGoNext,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _ChevronButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _ChevronButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.accent.withValues(alpha: enabled ? 1.0 : 0.3),
          ),
        ),
      ),
    );
  }
}

/// Trace discrète du montant « engagé » (résa confirmées non encore payées)
/// — affichée sous le delta uniquement si pipeline > 0.
class _PipelineLine extends StatelessWidget {
  final int amount;

  const _PipelineLine({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accent.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Engagé · ${FcfaFormatter.compact(amount)}',
          style: AppTextStyles.small.copyWith(
            fontSize: 11,
            color: AppColors.accent.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DeltaRow extends StatelessWidget {
  final int deltaPercent;
  final int previousAmount;
  final String previousMonthLabel;

  const _DeltaRow({
    required this.deltaPercent,
    required this.previousAmount,
    required this.previousMonthLabel,
  });

  @override
  Widget build(BuildContext context) {
    final positive = deltaPercent > 0;
    final negative = deltaPercent < 0;
    final tone = positive
        ? BadgeTone.success
        : (negative ? BadgeTone.danger : BadgeTone.neutral);
    final arrow = positive ? '↑' : (negative ? '↓' : '−');
    final pct = deltaPercent.abs();
    return Row(
      children: [
        BadgeStatus(text: '$arrow $pct%', tone: tone),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'vs. $previousMonthLabel · ${FcfaFormatter.compact(previousAmount)}',
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
