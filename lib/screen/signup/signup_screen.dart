import 'package:flutter/material.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/screen/signup/widget/signup_form.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';

/// Écran d'inscription par rôle.
///
/// Le rôle est passé depuis l'écran d'onboarding (`locataire`,
/// `proprietaire`, `demarcheur`) et appliqué automatiquement sur le
/// [UserReq] envoyé au signup.
class SignupScreen extends StatelessWidget {
  final String role;

  const SignupScreen({super.key, required this.role});

  String get _roleLabel {
    switch (role) {
      case 'proprietaire':
        return 'propriétaire';
      case 'demarcheur':
        return 'démarcheur';
      case 'locataire':
      default:
        return 'locataire';
    }
  }

  void _onLoginTap(BuildContext context) {
    pushScreenAndReplace(context, const LoginScreen());
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
              padding: const EdgeInsets.fromLTRB(28, 14, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconBoutton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => back(context),
                  ),
                  const SizedBox(height: 28),
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.display,
                      children: [
                        const TextSpan(text: 'Créer\n'),
                        TextSpan(
                          text: 'mon compte $_roleLabel.',
                          style: const TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Renseignez vos informations. Un code SMS vous sera envoyé pour valider votre numéro.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 28),
                  SignupForm(role: role),
                  const SizedBox(height: 22),
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
