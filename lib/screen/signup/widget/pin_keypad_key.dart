import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Touche individuelle du clavier [PinKeypad].
///
/// Affiche soit un chiffre ([label]), soit une icône ([icon]) — feedback
/// de pression à l'accent via InkWell.
class PinKeypadKey extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  const PinKeypadKey({super.key, this.label, this.icon, required this.onTap})
      : assert(label != null || icon != null, 'label ou icon requis');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgElev2,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        splashColor: AppColors.accent.withValues(alpha: 0.18),
        highlightColor: AppColors.accent.withValues(alpha: 0.10),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.line),
          ),
          child: Center(
            child: label != null
                ? Text(
                    label!,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Icon(icon, color: AppColors.text, size: 22),
          ),
        ),
      ),
    );
  }
}
