import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/mini_stats_inline.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Une stat individuelle du `MiniStatsInline` — eyebrow uppercase 9px +
/// valeur mono 15px bold.
class MiniStat extends StatelessWidget {
  final MiniStatItem item;

  const MiniStat({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label.toUpperCase(),
          style: AppTextStyles.eyebrow.copyWith(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.value,
          style: AppTextStyles.mono(TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: item.valueColor ?? Colors.white,
          )),
        ),
      ],
    );
  }
}
