import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Eyebrow de progression du tunnel d'inscription : « ÉTAPE X/4 ».
class SignupStepEyebrow extends StatelessWidget {
  /// Étape courante (1 à [totalSteps]).
  final int step;

  static const int totalSteps = 4;

  const SignupStepEyebrow({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    return Text(
      'ÉTAPE $step/$totalSteps',
      style: AppTextStyles.eyebrow.copyWith(color: AppColors.accent),
    );
  }
}
