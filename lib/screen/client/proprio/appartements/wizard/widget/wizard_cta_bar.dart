import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/bottom_nav/bottom_bar.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';

/// CTA bottom bar du wizard d'ajout d'appartement.
///
/// Label adaptatif :
/// - `currentStep < totalSteps` → "Continuer"
/// - `currentStep == totalSteps` → "Publier mon annonce"
///
/// Pendant la publication finale (`isPublishing`), affiche un spinner.
class WizardCtaBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool canNext;
  final bool isPublishing;
  final VoidCallback? onContinue;

  const WizardCtaBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.canNext,
    required this.isPublishing,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLastStep = currentStep >= totalSteps;
    final String label = isLastStep ? 'Publier mon annonce' : 'Continuer';
    final bool showLoading = isLastStep && isPublishing;
    final bool enabled = canNext && !isPublishing;
    return BottomBar(
      child: Opacity(
        opacity: enabled || showLoading ? 1.0 : 0.4,
        child: CustomButton(
          text: label,
          onPressed: enabled ? onContinue : null,
          size: ButtonSize.lg,
          block: true,
          loading: showLoading,
        ),
      ),
    );
  }

  /// Hauteur indicative pour réserver l'espace bottom du scroll.
  static const double indicativeHeight = 100;

  /// Couleur surface pour le scaffold (cohérence visuelle pendant le blur).
  static const Color surface = AppColors.background;
}
