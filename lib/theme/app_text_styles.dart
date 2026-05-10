import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Styles typographiques du design Asfar Premium.
///
/// 7 niveaux issus du prototype HTML : `display`, `h1`, `h2`, `h3`, `body`,
/// `small`, `eyebrow`. Helper `mono()` pour les chiffres tabulaires.
///
/// La famille de police par défaut est laissée au système (SF Pro sur iOS,
/// Roboto sur Android). Une bascule vers Inter via `google_fonts` pourra
/// être faite ultérieurement sans changer les callsites.
class AppTextStyles {
  AppTextStyles._();

  /// Titre display 32px — hero d'écrans (onboarding, confirmation).
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.05,
    color: AppColors.text,
  );

  /// Titre h1 26px — titres de pages, montants hero.
  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.15,
    color: AppColors.text,
  );

  /// Titre h2 20px — sections principales.
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
    color: AppColors.text,
  );

  /// Titre h3 17px — sous-sections, en-têtes de cards.
  static const TextStyle h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.text,
  );

  /// Corps de texte 15px — paragraphes, descriptions.
  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.45,
    color: AppColors.text2,
  );

  /// Petit texte 13px — métadonnées, captions.
  static const TextStyle small = TextStyle(
    fontSize: 13,
    color: AppColors.text2,
  );

  /// Eyebrow 11px uppercase — labels au-dessus des sections, status.
  static const TextStyle eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.text3,
  );

  /// Variante mono — applique `tabularFigures` pour aligner les chiffres
  /// dans les colonnes financières (montants FCFA, dates, codes de réservation).
  ///
  /// Usage : `AppTextStyles.mono(AppTextStyles.h2)`
  static TextStyle mono(TextStyle base) {
    return base.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}
