import 'package:flutter/material.dart';

/// Palette de 8 couleurs pour les avatars de conversation.
///
/// Contraste suffisant avec du texte blanc (AppColors.textOnAccent).
class AvatarColorPalette {
  AvatarColorPalette._();

  static const List<Color> _colors = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFD97706),
    Color(0xFF059669),
    Color(0xFF2563EB),
    Color(0xFFDC2626),
    Color(0xFF0D9488),
  ];

  static Color fromSeed(Object seed) =>
      _colors[seed.hashCode.abs() % _colors.length];

  static List<Color> get all => List.unmodifiable(_colors);
}
