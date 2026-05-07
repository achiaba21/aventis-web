import 'package:flutter/material.dart';

import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/widget/wizard/wizard_auto_save_indicator.dart';
import 'package:asfar/widget/wizard/wizard_circle_progress.dart';

/// Squelette d'une étape du wizard.
///
/// Compose :
/// - Une AppBar minimale (back/titre/close)
/// - L'indicateur de progression [WizardCircleProgress]
/// - Le contenu fourni par [child] (peut occuper tout l'espace disponible)
/// - Une [bottomBar] optionnelle (typiquement [WizardNavigationBar])
/// - Un [WizardAutoSaveIndicator] flottant en bas-droite quand [isSaving]
class WizardStepScaffold extends StatelessWidget {
  const WizardStepScaffold({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    this.bottomBar,
    this.isSaving = false,
    this.onBack,
    this.onClose,
  });

  final String title;
  final int currentStep;
  final int totalSteps;
  final Widget child;
  final Widget? bottomBar;
  final bool isSaving;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: onBack,
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: TextSeed(
          title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Espacement.paddingInput,
                ),
                child: WizardCircleProgress(
                  currentStep: currentStep,
                  totalSteps: totalSteps,
                ),
              ),
              Expanded(child: child),
            ],
          ),
          Positioned(
            right: Espacement.paddingBloc,
            bottom: Espacement.paddingBloc,
            child: WizardAutoSaveIndicator(isSaving: isSaving),
          ),
        ],
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}
