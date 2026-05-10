import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Une barre individuelle du `Sparkbar`.
///
/// Si `month.highlight` est true, affiche en accent or avec étiquette
/// flottante du montant compact au-dessus. Sinon, affiche en bgElev3.
class SparkbarBar extends StatelessWidget {
  final MonthlyRevenue month;
  final int maxAmount;
  final double containerHeight;

  const SparkbarBar({
    super.key,
    required this.month,
    required this.maxAmount,
    required this.containerHeight,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount == 0 ? 0.0 : month.amount / maxAmount;
    final barHeight = (containerHeight * ratio)
        .clamp(containerHeight * 0.1, containerHeight);

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
              color: month.highlight ? AppColors.accent : AppColors.bgElev3,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (month.highlight)
            Positioned(
              bottom: barHeight + 2,
              child: Text(
                FcfaFormatter.compact(month.amount),
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
