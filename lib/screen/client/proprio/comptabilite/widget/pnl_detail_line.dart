import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Ligne détaillée d'une catégorie du `PnLCard`, indentée à 12px.
class PnLDetailLine extends StatelessWidget {
  final PnLEntry entry;

  const PnLDetailLine({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 0, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              entry.label,
              style: const TextStyle(fontSize: 13, color: AppColors.text2),
            ),
          ),
          Text(
            FcfaFormatter.compact(entry.amount),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 13,
              color: AppColors.text2,
            )),
          ),
        ],
      ),
    );
  }
}
