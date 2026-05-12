import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Row : badge delta signé ↑/↓/− avec tone calculé automatiquement
/// + label « vs. {previousLabel} · {previousAmount} ».
///
/// Atome partagé entre `RevenueHeroCard` et `BeneficeNetHeroCard`. Le
/// `tone` est dérivé du signe : positif=success, négatif=danger, zéro=neutral.
class DeltaBadgeRow extends StatelessWidget {
  final int deltaPercent;
  final int previousAmount;
  final String previousLabel;
  final Color? textColor;

  const DeltaBadgeRow({
    super.key,
    required this.deltaPercent,
    required this.previousAmount,
    required this.previousLabel,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final positive = deltaPercent > 0;
    final negative = deltaPercent < 0;
    final tone = positive
        ? BadgeTone.success
        : (negative ? BadgeTone.danger : BadgeTone.neutral);
    final arrow = positive ? '↑' : (negative ? '↓' : '−');
    return Row(
      children: [
        BadgeStatus(text: '$arrow ${deltaPercent.abs()}%', tone: tone),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'vs. $previousLabel · ${FcfaFormatter.compact(previousAmount)}',
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: textColor ?? AppColors.text2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
