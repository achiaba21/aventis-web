import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Affiche une SnackBar d'erreur (fond danger) — pattern standard du projet
/// pour relayer un message d'échec (validation, erreur serveur).
void showDangerSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.danger,
    ),
  );
}
