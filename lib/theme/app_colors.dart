import 'package:flutter/material.dart';

/// Source unique de toutes les couleurs de l'application.
///
/// Identité visuelle : fond blanc, texte noir, orange en accent tertiaire.
/// Aucune couleur ne doit être définie hors de ce fichier (et des palettes dédiées).
class AppColors {
  AppColors._();

  // ============ FONDS ============
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceElevated = Color(0xFFFAFAFA);

  // ============ TEXTES ============
  static const Color textPrimary = Color(0xFF1D1D1D);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textMuted = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // ============ ACCENT TERTIAIRE (ORANGE MARQUE) ============
  static const Color accent = Color(0xFFFFA02A);
  static const Color accentDark = Color(0xFFE08A1F);
  static const Color accentLight = Color(0xFFFFF1DC);

  // ============ SÉMANTIQUE ============
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFEB4040);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============ BORDURES & SÉPARATEURS ============
  static const Color border = Color(0xFF000000);
  static const Color divider = Color(0xFFEEEEEE);

  // ============ ÉTATS ============
  static const Color inactive = Color(0xFFBDBDBD);
  static const Color disabled = Color(0xFFEEEEEE);

  // ============ OMBRES & OVERLAYS ============
  static final Color shadow = const Color(0xFF000000).withValues(alpha: 0.08);
  static final Color shadowStrong =
      const Color(0xFF000000).withValues(alpha: 0.15);
  static final Color overlay = const Color(0xFF000000).withValues(alpha: 0.5);
  static final Color overlayLight =
      const Color(0xFF000000).withValues(alpha: 0.2);

  // ============ CALENDRIER ============
  static const Color calendarBlocked = Color(0xFFE0E0E0);
  static const Color calendarReserved = accent;
  static const Color calendarAvailable = success;

  // ============ PRIMITIVES (usage restreint) ============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
