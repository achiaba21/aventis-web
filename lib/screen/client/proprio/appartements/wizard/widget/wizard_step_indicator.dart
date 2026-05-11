import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Header de wizard : back + titre + sub "Étape X / N" + progress bar
/// animée 4px. Reproduit `proprietaire-extras.jsx::ProprietaireAddListing`
/// TopNav + progress wrapper (lignes 30-43).
class WizardStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String title;
  final VoidCallback onBack;

  const WizardStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    this.title = 'Nouvelle annonce',
  });

  @override
  Widget build(BuildContext context) {
    final double progress = currentStep / totalSteps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconBoutton(
                icon: Icons.arrow_back_ios_new,
                onPressed: onBack,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Étape $currentStep / $totalSteps',
                      style: AppTextStyles.small.copyWith(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 44), // équilibre visuel du back button
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LayoutBuilder(builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 4,
                    width: constraints.maxWidth,
                    color: AppColors.bgElev2,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 4,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    color: AppColors.accent,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
