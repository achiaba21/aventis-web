import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/cashflow_segment.dart';
import 'package:asfar/screen/client/proprio/home/widget/cashflow_legend_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card « Flux financier » du Dashboard propriétaire — barre stack 4 segments
/// + légende.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireDashboard`
/// (lignes 93-118) : barre horizontale `radius: 99 height: 14` avec 4
/// segments proportionnels (somme des `amount` détermine les ratios), suivie
/// de 4 lignes de légende avec dot couleur + label + montant aligné à droite.
class CashflowSplitCard extends StatelessWidget {
  final List<CashflowSegment> segments;

  const CashflowSplitCard({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<int>(0, (s, seg) => s + seg.amount);
    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              height: 14,
              child: Row(
                children: [
                  for (final seg in segments)
                    Expanded(
                      flex: seg.amount,
                      child: Container(color: seg.color),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final seg in segments) CashflowLegendRow(segment: seg),
        ],
      ),
    );
  }
}
