import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Stepper -/+ pour ajuster une valeur entière (Chambres / SdB).
///
/// Reproduit `proprietaire-extras.jsx::Stepper` (lignes 440-459).
/// Affiche un eyebrow + Container bgElev2 avec :
/// - bouton − rond 28px bgElev3 (disabled si value=min)
/// - valeur mono center
/// - bouton + rond 28px accent or
class WizardStepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChange;

  const WizardStepperRow({
    super.key,
    required this.label,
    required this.value,
    this.min = 0,
    this.max = 20,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final bool canDecrement = value > min;
    final bool canIncrement = value < max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.eyebrow,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgElev2,
            border: Border.all(color: AppColors.line, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepperButton(
                icon: Icons.remove,
                background: AppColors.bgElev3,
                foreground: AppColors.text,
                enabled: canDecrement,
                onTap: canDecrement ? () => onChange(value - 1) : null,
              ),
              Text(
                '$value',
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                )),
              ),
              _StepperButton(
                icon: Icons.add,
                background: AppColors.accent,
                foreground: AppColors.onAccent,
                enabled: canIncrement,
                onTap: canIncrement ? () => onChange(value + 1) : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool enabled;
  final VoidCallback? onTap;

  const _StepperButton({
    required this.icon,
    required this.background,
    required this.foreground,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: foreground),
          ),
        ),
      ),
    );
  }
}
