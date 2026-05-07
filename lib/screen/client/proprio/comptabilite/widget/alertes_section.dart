import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Section des alertes pour les charges en retard ou à venir
class AlertesSection extends StatelessWidget {
  final List<Charge> alertes;

  const AlertesSection({super.key, required this.alertes});

  @override
  Widget build(BuildContext context) {
    final enRetard = alertes.where((c) => c.estEnRetard).toList();
    final aVenir = alertes.where((c) => c.echeanceProche && !c.estEnRetard).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: enRetard.isNotEmpty
            ? AppColors.errorLight
            : AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enRetard.isNotEmpty ? AppColors.error : AppColors.warning,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: enRetard.isNotEmpty ? AppColors.error : AppColors.warning,
              ),
              const SizedBox(width: 8),
              TextSeed(
                "Alertes (${alertes.length})",
                fontWeight: FontWeight.bold,
                color: enRetard.isNotEmpty ? AppColors.error : AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (enRetard.isNotEmpty) ...[
            TextSeed(
              "${enRetard.length} charge(s) en retard",
              fontSize: 14,
              color: AppColors.error,
            ),
            const SizedBox(height: 4),
          ],
          if (aVenir.isNotEmpty)
            TextSeed(
              "${aVenir.length} charge(s) à payer cette semaine",
              fontSize: 14,
              color: AppColors.warning,
            ),
        ],
      ),
    );
  }
}
