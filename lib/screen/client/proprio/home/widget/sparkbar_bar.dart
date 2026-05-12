import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/monthly_revenue.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Une barre individuelle du `Sparkbar` — composite encaissé + pipeline.
///
/// Le bas de la barre est en accent or opaque (montant encaissé), le haut
/// est en accent or translucide (montant engagé/pipeline). Étiquette
/// flottante = encaissé seul (cohérent avec le montant principal du hero).
///
/// Quand `active`, l'étiquette est visible. Quand encaissé + pipeline = 0,
/// affiche un placeholder gris bgElev3 à 10% de la hauteur.
class SparkbarBar extends StatelessWidget {
  final MonthlyRevenue month;
  final int maxAmount;
  final double containerHeight;
  final bool active;
  final VoidCallback? onTap;

  const SparkbarBar({
    super.key,
    required this.month,
    required this.maxAmount,
    required this.containerHeight,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final encaissedHeight = _heightFor(month.amount);
    final pipelineHeight = _heightFor(month.pipeline);
    final totalHeight = encaissedHeight + pipelineHeight;
    final isEmpty = totalHeight <= 0;
    final renderedHeight = isEmpty
        ? containerHeight * 0.1
        : totalHeight.clamp(containerHeight * 0.1, containerHeight);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              SizedBox(
                height: renderedHeight,
                width: double.infinity,
                child: isEmpty
                    ? Container(
                        decoration: BoxDecoration(
                          color: AppColors.bgElev3,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Column(
                          children: [
                            if (pipelineHeight > 0)
                              SizedBox(
                                height: pipelineHeight,
                                width: double.infinity,
                                child: Container(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                            if (encaissedHeight > 0)
                              SizedBox(
                                height: encaissedHeight,
                                width: double.infinity,
                                child: Container(color: AppColors.accent),
                              ),
                          ],
                        ),
                      ),
              ),
              if (active && month.amount > 0)
                Positioned(
                  bottom: renderedHeight + 2,
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
        ),
      ),
    );
  }

  double _heightFor(int amount) {
    if (maxAmount <= 0 || amount <= 0) return 0;
    return containerHeight * (amount / maxAmount);
  }
}
