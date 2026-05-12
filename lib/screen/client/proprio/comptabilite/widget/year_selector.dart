import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/finance/accent_chevron_button.dart';

/// Sélecteur d'année du `ProprioFinancesScreen`.
///
/// Discret, placé au-dessus du `PeriodSwitcher`. Chevrons ‹ › centrés autour
/// de l'année. Chevron `›` désactivé quand on est sur l'année courante
/// (pas de futur).
class YearSelector extends StatelessWidget {
  final int year;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const YearSelector({
    super.key,
    required this.year,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AccentChevronButton(
            icon: Icons.chevron_left,
            enabled: canGoPrev,
            onTap: onPrev,
            iconSize: 16,
            padding: 3,
            color: AppColors.text,
            disabledAlpha: 0.25,
          ),
          const SizedBox(width: 8),
          Text(
            '$year',
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 8),
          AccentChevronButton(
            icon: Icons.chevron_right,
            enabled: canGoNext,
            onTap: onNext,
            iconSize: 16,
            padding: 3,
            color: AppColors.text,
            disabledAlpha: 0.25,
          ),
        ],
      ),
    );
  }
}
