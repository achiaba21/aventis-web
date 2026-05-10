import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/pnl_entry.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Ligne « Bénéfice net » du footer du `PnLCard` — accent or 18px bold.
class PnLNetIncomeRow extends StatelessWidget {
  final PnLEntry netIncome;

  const PnLNetIncomeRow({super.key, required this.netIncome});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bénéfice net',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        Text(
          FcfaFormatter.compact(netIncome.amount),
          style: AppTextStyles.mono(const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          )),
        ),
      ],
    );
  }
}
