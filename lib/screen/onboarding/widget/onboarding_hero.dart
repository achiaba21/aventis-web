import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Hero de l'écran d'onboarding.
///
/// Logo carré "A" or + nom asfar, headline display sur 3 lignes
/// (« Voyagez, louez, gagnez. » — dernier mot en accent), pitch en body.
/// Reproduit `extras.jsx::Onboarding` (haut de page).
class OnboardingHero extends StatelessWidget {
  const OnboardingHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text(
                'A',
                style: TextStyle(
                  color: AppColors.onAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'asfar',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: AppColors.text,
              ),
            ),
          ],
        ),
        const SizedBox(height: 60),
        Text.rich(
          TextSpan(
            style: AppTextStyles.display,
            children: const [
              TextSpan(text: 'Voyagez,\nlouez,\n'),
              TextSpan(
                text: 'gagnez.',
                style: TextStyle(color: AppColors.accent),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'La plateforme de location meublée qui connecte voyageurs, propriétaires et démarcheurs.',
          style: AppTextStyles.body,
        ),
      ],
    );
  }
}
