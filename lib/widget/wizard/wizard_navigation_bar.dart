import 'package:flutter/material.dart';

import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Bottom bar de navigation du wizard.
///
/// - Bouton "Précédent" caché à l'étape 1.
/// - Bouton "Continuer" sur les étapes 1..N-1, "Publier" sur la dernière.
/// - Le bouton "Publier" est désactivé tant que [canPublish] est `false`.
class WizardNavigationBar extends StatelessWidget {
  const WizardNavigationBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.canPublish,
    this.isPublishing = false,
    this.isEditing = false,
    this.onPrev,
    this.onNext,
    this.onPublish,
  });

  final int currentStep;
  final int totalSteps;
  final bool canPublish;
  final bool isPublishing;
  final bool isEditing;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onPublish;

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep >= totalSteps;
    final showPrev = currentStep > 1;

    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (showPrev) ...[
              Expanded(
                child: OutlinedCustomButton(
                  text: "Précédent",
                  onPressed: onPrev,
                ),
              ),
              SizedBox(width: Espacement.gapSection),
            ],
            Expanded(
              flex: 2,
              child: _buildPrimaryButton(isLastStep),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(bool isLastStep) {
    if (isPublishing) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: Espacement.paddingInput),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.background),
              ),
            ),
            SizedBox(width: Espacement.gapSection),
            TextSeed(
              "Publication...",
              color: AppColors.background,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      );
    }

    if (isLastStep) {
      final label = isEditing ? "Enregistrer" : "Publier";
      return PlainButton(
        value: label,
        color: canPublish ? AppColors.accent : AppColors.inactive,
        onPress: canPublish ? onPublish : null,
      );
    }

    return PlainButton(
      value: "Continuer",
      color: AppColors.accent,
      onPress: onNext,
    );
  }
}
