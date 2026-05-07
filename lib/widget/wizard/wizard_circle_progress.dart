import 'package:flutter/material.dart';

import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';

/// Indicateur de progression compact du wizard.
///
/// Affiche [totalSteps] cercles horizontaux. Les [currentStep] premiers
/// cercles sont remplis (accent orange), les suivants sont outlined gris.
class WizardCircleProgress extends StatelessWidget {
  const WizardCircleProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.dotSize = 12,
  });

  final int currentStep;
  final int totalSteps;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isFilled = index < currentStep;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: Espacement.gapItem),
          child: Container(
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isFilled ? AppColors.accent : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isFilled ? AppColors.accent : AppColors.divider,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
