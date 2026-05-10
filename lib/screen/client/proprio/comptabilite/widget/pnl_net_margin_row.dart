import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Ligne « Marge nette » du footer du `PnLCard` — small success 11px.
class PnLNetMarginRow extends StatelessWidget {
  final PnLEntry netMargin;

  const PnLNetMarginRow({super.key, required this.netMargin});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Marge nette',
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
        Text(
          '${netMargin.amount}%',
          style: AppTextStyles.mono(const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          )),
        ),
      ],
    );
  }
}
