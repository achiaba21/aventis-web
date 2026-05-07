import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/theme/app_colors.dart';

/// Configuration du thème Material 3 de l'application.
///
/// Mode clair uniquement (fond blanc, texte noir, accent orange tertiaire).
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          onPrimary: AppColors.textOnAccent,
          secondary: AppColors.textPrimary,
          onSecondary: AppColors.background,
          surface: AppColors.surface,
          onSurface: AppColors.textPrimary,
          error: AppColors.error,
          onError: AppColors.textOnAccent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        dividerColor: AppColors.divider,
      );
}
