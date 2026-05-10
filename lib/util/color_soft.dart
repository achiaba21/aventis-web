import 'package:flutter/material.dart';

/// Extension utilitaire pour obtenir une variante translucide d'une couleur.
///
/// Usage : `AppColors.warn.soft14()` → fond accentué à 14% d'opacité (pattern
/// systématique du design Asfar Premium pour les status badges, banners, etc.).
extension ColorSoft on Color {
  /// Retourne la même couleur avec un alpha de 14% (0x24 = 36/255 ≈ 14.1%).
  ///
  /// 14% est l'alpha standard du proto pour les fonds soft (chip-active,
  /// banners accent, badges sémantiques, payment tiles).
  Color soft14() => withValues(alpha: 0.14);

  /// Variante alpha personnalisée — alias plus court pour `withValues(alpha:)`.
  Color softAlpha(double alpha) => withValues(alpha: alpha);
}
