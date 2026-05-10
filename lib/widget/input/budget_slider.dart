import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Slider custom du design Asfar Premium — utilisé dans Search filtres.
///
/// Track inactif `bgElev3`, track actif `accent`, thumb cercle accent
/// avec halo subtil.
class BudgetSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double? step;
  final ValueChanged<double>? onChanged;

  const BudgetSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    this.step,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.bgElev3,
        thumbColor: AppColors.accent,
        overlayColor: AppColors.accent.withValues(alpha: 0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
        valueIndicatorColor: AppColors.accent,
        valueIndicatorTextStyle: const TextStyle(
          color: AppColors.onAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Slider(
        value: value.clamp(min, max),
        min: min,
        max: max,
        divisions:
            step != null ? ((max - min) / step!).round() : null,
        onChanged: onChanged,
      ),
    );
  }
}
