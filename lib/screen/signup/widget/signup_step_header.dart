import 'package:flutter/material.dart';
import 'package:asfar/screen/signup/widget/signup_step_eyebrow.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// En-tête commun des écrans du tunnel d'inscription : eyebrow « ÉTAPE X/4 »,
/// titre display sur 2 lignes (2ᵉ ligne accent), sous-titre explicatif.
class SignupStepHeader extends StatelessWidget {
  final int step;
  final String titleLine1;
  final String titleLine2;
  final String subtitle;

  const SignupStepHeader({
    super.key,
    required this.step,
    required this.titleLine1,
    required this.titleLine2,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SignupStepEyebrow(step: step),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(
            style: AppTextStyles.display,
            children: [
              TextSpan(text: '$titleLine1\n'),
              TextSpan(
                text: titleLine2,
                style: const TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(subtitle, style: AppTextStyles.body),
      ],
    );
  }
}
