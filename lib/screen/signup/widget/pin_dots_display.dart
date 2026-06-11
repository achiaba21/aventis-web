import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Rangée de cellules affichant la progression d'une saisie de code PIN.
///
/// Purement visuel — la saisie est pilotée par un clavier dédié
/// ([PinKeypad]) : chaque chiffre saisi remplit une cellule (`●`).
/// La cellule courante est soulignée à l'accent ; [hasError] passe
/// toutes les bordures en danger (confirmation non concordante).
class PinDotsDisplay extends StatelessWidget {
  /// Nombre de chiffres déjà saisis.
  final int filledCount;

  /// Longueur totale du code.
  final int length;

  /// Affiche l'état d'erreur (bordures danger).
  final bool hasError;

  const PinDotsDisplay({
    super.key,
    required this.filledCount,
    this.length = 5,
    this.hasError = false,
  });

  Color _borderColorFor(int index) {
    if (hasError) return AppColors.danger;
    if (index == filledCount) return AppColors.accent;
    return AppColors.line;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Container(
              width: 48,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.bgElev2,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(
                  color: _borderColorFor(i),
                  width: (hasError || i == filledCount) ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  i < filledCount ? '●' : '',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
