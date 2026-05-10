import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/cashflow_segment.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

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
          for (final seg in segments) _legendRow(seg),
        ],
      ),
    );
  }

  Widget _legendRow(CashflowSegment seg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: seg.color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              seg.label,
              style: const TextStyle(fontSize: 13, color: AppColors.text2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            FcfaFormatter.compact(seg.amount),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            )),
          ),
        ],
      ),
    );
  }
}
