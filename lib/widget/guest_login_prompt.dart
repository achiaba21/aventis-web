import 'package:flutter/material.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget qui affiche un message de connexion pour les utilisateurs invités
class GuestLoginPrompt extends StatelessWidget {
  final String message;

  const GuestLoginPrompt({
    super.key,
    this.message = "Connectez-vous pour accéder à cette fonctionnalité",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: AppColors.textMuted),
            SizedBox(height: 24),
            TextSeed(
              "Connexion requise",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 8),
            TextSeed(
              message,
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 32),
            PlainButton(
              value: "Se connecter",
              onPress: () => pushScreen(context, LoginScreen()),
            ),
          ],
        ),
      ),
    );
  }
}
