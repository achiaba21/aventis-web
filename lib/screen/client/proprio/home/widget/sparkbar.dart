import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/screen/client/proprio/home/widget/sparkbar_bar.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bar chart simple à barres verticales — atome.
///
/// Reproduit la `sparkbar` du proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 56-75) : 6 barres ratio hauteur, la barre `selected` est rendue
/// en accent or avec étiquette flottante. Les barres sont tappables pour
/// permettre la navigation rapide vers le mois cliqué.
class Sparkbar extends StatelessWidget {
  final List<MonthlyRevenue> months;
  final DateTime? selectedMonth;
  final ValueChanged<MonthlyRevenue>? onBarTap;
  final double height;

  const Sparkbar({
    super.key,
    required this.months,
    this.selectedMonth,
    this.onBarTap,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return SizedBox(height: height);
    }
    final maxAmount = months
        .map((m) => m.total)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: height + 22,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final m in months)
                Expanded(
                  child: SparkbarBar(
                    month: m,
                    maxAmount: maxAmount,
                    containerHeight: height,
                    active: selectedMonth != null && m.sameMonthAs(selectedMonth!),
                    onTap: onBarTap == null ? null : () => onBarTap!(m),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final m in months)
              () {
                final isSelected =
                    selectedMonth != null && m.sameMonthAs(selectedMonth!);
                return Expanded(
                  child: Text(
                    m.monthShort,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.accent
                          : Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }(),
          ],
        ),
      ],
    );
  }
}
