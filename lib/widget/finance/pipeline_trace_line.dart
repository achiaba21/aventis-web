import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Trace discrète d'un montant secondaire — typiquement « Engagé · X FCFA »
/// pour le pipeline résa confirmées non encore payées.
///
/// Atome partagé entre `RevenueHeroCard` et `BeneficeNetHeroCard`. Pourrait
/// servir ailleurs pour signaler n'importe quel montant secondaire (en
/// attente, projeté, etc.) via le paramètre `label`.
class PipelineTraceLine extends StatelessWidget {
  final int amount;
  final String label;
  final Color color;
  final double textAlpha;
  final double dotAlpha;

  const PipelineTraceLine({
    super.key,
    required this.amount,
    this.label = 'Engagé',
    this.color = AppColors.accent,
    this.textAlpha = 0.85,
    this.dotAlpha = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: dotAlpha),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label · ${FcfaFormatter.compact(amount)}',
          style: AppTextStyles.small.copyWith(
            fontSize: 11,
            color: color.withValues(alpha: textAlpha),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
