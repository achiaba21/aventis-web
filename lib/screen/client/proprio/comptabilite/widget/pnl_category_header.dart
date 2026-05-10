import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Header de catégorie du `PnLCard` : label coloré (success/danger selon
/// isRevenue) + total mono.
class PnLCategoryHeader extends StatelessWidget {
  final PnLEntry entry;

  const PnLCategoryHeader({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = entry.isRevenue ? AppColors.success : AppColors.danger;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            entry.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            FcfaFormatter.compact(entry.amount),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            )),
          ),
        ],
      ),
    );
  }
}
