import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Configuration du thème Material 3 de l'application.
///
/// **Asfar Dark Premium** : fond quasi-noir, accent or chaud, identité
/// hospitalité + luxe africain. Mode dark uniquement (pas de toggle clair/dark
/// par décision produit).
class AppTheme {
  AppTheme._();

  /// Thème Asfar Dark — unique thème de l'application.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: AppColors.onAccent,
          secondary: AppColors.accent2,
          onSecondary: AppColors.onAccent,
          surface: AppColors.surface,
          onSurface: AppColors.text,
          surfaceContainerHighest: AppColors.bgElev2,
          surfaceContainerHigh: AppColors.bgElev1,
          error: AppColors.error,
          onError: AppColors.text,
          outline: AppColors.line,
          outlineVariant: AppColors.lineStrong,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: AppTextStyles.h3,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Color(0x00000000),
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.bgElev1,
          surfaceTintColor: AppColors.bgElev1,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: const BorderSide(color: AppColors.line, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bgElev2,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.text3),
          labelStyle: AppTextStyles.small.copyWith(color: AppColors.text3),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.line, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.background,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.text3,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.bgElev1,
          surfaceTintColor: AppColors.bgElev1,
          modalBackgroundColor: AppColors.bgElev1,
          modalElevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.bgElev1,
          surfaceTintColor: AppColors.bgElev1,
          elevation: 0,
        ),
        dividerColor: AppColors.line,
        dividerTheme: const DividerThemeData(
          color: AppColors.line,
          thickness: 1,
          space: 1,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.display,
          displayMedium: AppTextStyles.display,
          displaySmall: AppTextStyles.display,
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h1,
          headlineSmall: AppTextStyles.h2,
          titleLarge: AppTextStyles.h2,
          titleMedium: AppTextStyles.h3,
          titleSmall: AppTextStyles.h3,
          bodyLarge: AppTextStyles.body,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.small,
          labelLarge: AppTextStyles.h3,
          labelMedium: AppTextStyles.small,
          labelSmall: AppTextStyles.eyebrow,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.text2,
          size: 22,
        ),
      );
}
