import 'package:flutter/material.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/screen/onboarding/widget/onboarding_hero.dart';
import 'package:asfar/screen/onboarding/widget/onboarding_role_card.dart';
import 'package:asfar/screen/signup/signup_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';

/// Écran d'onboarding avec choix de rôle.
///
/// Reproduit `extras.jsx::Onboarding` : double halo radial or, hero
/// (logo + display title + pitch), 3 cards de rôle (Locataire / Propriétaire
/// / Démarcheur), lien bas vers Login.
///
/// Le tap sur un rôle navigue vers le tunnel d'auth correspondant
/// (à brancher en Vague 4 — Auth).
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onPickRole(BuildContext context, String role) {
    pushScreen(context, SignupScreen(role: role));
  }

  void _onLoginTap(BuildContext context) {
    pushScreen(context, const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const AuthRadialBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 60, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const OnboardingHero(),
                  const SizedBox(height: 50),
                  const Text('JE SUIS…', style: AppTextStyles.eyebrow),
                  const SizedBox(height: 14),
                  OnboardingRoleCard(
                    icon: Icons.vpn_key_outlined,
                    title: 'Locataire',
                    subtitle: 'Trouver un logement à louer',
                    onTap: () => _onPickRole(context, 'locataire'),
                  ),
                  const SizedBox(height: 10),
                  OnboardingRoleCard(
                    icon: Icons.home_outlined,
                    title: 'Propriétaire',
                    subtitle: 'Mettre mon bien en location',
                    onTap: () => _onPickRole(context, 'proprietaire'),
                  ),
                  const SizedBox(height: 10),
                  OnboardingRoleCard(
                    icon: Icons.handshake_outlined,
                    title: 'Démarcheur',
                    subtitle: 'Référer des clients & gagner des commissions',
                    onTap: () => _onPickRole(context, 'demarcheur'),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Vous avez déjà un compte ? ',
                          style: AppTextStyles.small.copyWith(fontSize: 13),
                        ),
                        InkWell(
                          onTap: () => _onLoginTap(context),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
