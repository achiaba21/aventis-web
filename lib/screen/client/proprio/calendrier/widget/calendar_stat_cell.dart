import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Cellule statistique du `CalendarStatsRow` — eyebrow UPPERCASE + valeur tonée.
///
/// 3 tons (danger/success/accent) pour les 3 stats (Occupé/Libre/Manque à gagner).
class CalendarStatCell extends StatelessWidget {
  final String label;
  final String value;
  final Color tone;

  const CalendarStatCell({
    super.key,
    required this.label,
    required this.value,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.eyebrow),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.mono(TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: tone,
              letterSpacing: -0.3,
            )),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
