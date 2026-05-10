import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/proprio_kpi.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Tile d'un KPI du Dashboard propriétaire (grid 2×2).
///
/// Reproduit le composant `Stat` du proto `shared.jsx` (utilisé lignes 80-86
/// de `proprietaire.jsx::ProprietaireDashboard`) : eyebrow label + valeur mono
/// bold + delta % en couleur (success si positif, danger si négatif).
class KpiTile extends StatelessWidget {
  final ProprioKpi kpi;

  const KpiTile({super.key, required this.kpi});

  @override
  Widget build(BuildContext context) {
    final positive = kpi.deltaPercent >= 0;
    final deltaColor = positive ? AppColors.success : AppColors.danger;
    final deltaPrefix = positive ? '+' : '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpi.label.toUpperCase(),
            style: AppTextStyles.eyebrow.copyWith(fontSize: 10),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                kpi.value,
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                )),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '$deltaPrefix${kpi.deltaPercent}%',
                  style: AppTextStyles.mono(TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: deltaColor,
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
