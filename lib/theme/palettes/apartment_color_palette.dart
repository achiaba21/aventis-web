import 'package:flutter/material.dart';

/// Palette de 20 couleurs distinctes pour identifier visuellement les appartements.
///
/// Saturation 70-85%, lightness 40-55% : bon contraste sur fond clair (blanc/gris).
class ApartmentColorPalette {
  ApartmentColorPalette._();

  static const List<Color> _colors = [
    Color(0xFFD32F2F),
    Color(0xFF388E3C),
    Color(0xFF1976D2),
    Color(0xFFF57C00),
    Color(0xFF7B1FA2),
    Color(0xFF00838F),
    Color(0xFFC2185B),
    Color(0xFF512DA8),
    Color(0xFF00796B),
    Color(0xFFF9A825),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFFE53935),
    Color(0xFF43A047),
    Color(0xFF1E88E5),
    Color(0xFFEF6C00),
    Color(0xFF8E24AA),
    Color(0xFF0097A7),
    Color(0xFFD81B60),
    Color(0xFF5E35B1),
  ];

  static Color colorAt(int index) => _colors[index % _colors.length];

  static Color colorForId(int id) => _colors[id.abs() % _colors.length];

  static List<Color> get all => List.unmodifiable(_colors);
}
