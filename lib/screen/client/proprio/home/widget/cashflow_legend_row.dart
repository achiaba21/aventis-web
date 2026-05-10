import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/cashflow_segment.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Une ligne de la légende sous la barre `CashflowSplitCard` :
/// dot couleur du segment + label + montant compact aligné à droite.
class CashflowLegendRow extends StatelessWidget {
  final CashflowSegment segment;

  const CashflowLegendRow({super.key, required this.segment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: segment.color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              segment.label,
              style: const TextStyle(fontSize: 13, color: AppColors.text2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            FcfaFormatter.compact(segment.amount),
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
