import 'package:flutter/material.dart';
import 'package:asfar/screen/login/widget/login_form.dart';
import 'package:asfar/screen/signup/signup_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/container/auth_radial_background.dart';

/// Écran de connexion (option A — continuité prototype).
///
/// Hero radial or, logo, display title (« Bienvenue, connectez-vous. »),
/// formulaire [LoginForm], lien vers Signup en footer.
class LoginScreen extends StatelessWidget {
  /// Si fourni, [signupRole] est utilisé pour pré-sélectionner le rôle
  /// quand on clique sur "S'inscrire" depuis cet écran.
  final String? signupRole;

  const LoginScreen({super.key, this.signupRole});

  void _onSignupTap(BuildContext context) {
    if (signupRole != null) {
      pushScreenAndReplace(context, SignupScreen(role: signupRole!));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez d\'abord un rôle depuis l\'accueil'),
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                  const SizedBox(height: 36),
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.display,
                      children: const [
                        TextSpan(text: 'Bienvenue,\n'),
                        TextSpan(
                          text: 'connectez-vous.',
                          style: TextStyle(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Entrez votre email ou téléphone et votre mot de passe.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 32),
                  const LoginForm(),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Pas de compte ? ',
                          style: AppTextStyles.small.copyWith(fontSize: 13),
                        ),
                        InkWell(
                          onTap: () => _onSignupTap(context),
                          child: const Text(
                            "S'inscrire",
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
