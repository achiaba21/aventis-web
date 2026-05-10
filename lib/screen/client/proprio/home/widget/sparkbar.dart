import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Bar chart simple à barres verticales — atome de Vague 7.
///
/// Reproduit la `sparkbar` du proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 56-75) : 6 barres ratio hauteur, dernière barre `highlight: true`
/// affichée en accent or avec étiquette flottante au-dessus, autres en
/// `bgElev3`.
///
/// Une row de labels (mois courts) est affichée en-dessous des barres.
class Sparkbar extends StatelessWidget {
  final List<MonthlyRevenue> months;
  final double height;

  const Sparkbar({
    super.key,
    required this.months,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) {
      return SizedBox(height: height);
    }
    final maxAmount = months
        .map((m) => m.amount)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        SizedBox(
          height: height + 22,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final m in months)
                Expanded(child: _bar(m, maxAmount)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final m in months)
              Expanded(
                child: Text(
                  m.monthShort,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _bar(MonthlyRevenue m, int maxAmount) {
    final ratio = m.amount / maxAmount;
    final barHeight = (height * ratio).clamp(height * 0.1, height);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: barHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: m.highlight ? AppColors.accent : AppColors.bgElev3,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (m.highlight)
            Positioned(
              bottom: barHeight + 2,
              child: Text(
                FcfaFormatter.compact(m.amount),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
