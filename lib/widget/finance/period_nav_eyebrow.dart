import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/finance/accent_chevron_button.dart';

/// Eyebrow avec chevrons ‹ › collés à gauche et à droite du libellé.
///
/// Atome partagé entre `RevenueHeroCard` (Dashboard, accent or sur gradient)
/// et `BeneficeNetHeroCard` (Finances, accent or sur bgElev1). Le caller
/// fournit le texte + l'état des chevrons + les callbacks.
class PeriodNavEyebrow extends StatelessWidget {
  final String label;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Color color;
  final double fontSize;

  const PeriodNavEyebrow({
    super.key,
    required this.label,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
    this.color = AppColors.accent,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AccentChevronButton(
          icon: Icons.chevron_left,
          enabled: canGoPrev,
          onTap: onPrev,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: AppTextStyles.eyebrow.copyWith(
            color: color,
            fontSize: fontSize,
          ),
        ),
        const SizedBox(width: 2),
        AccentChevronButton(
          icon: Icons.chevron_right,
          enabled: canGoNext,
          onTap: onNext,
          color: color,
        ),
      ],
    );
  }
}
