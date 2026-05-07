import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/palettes/apartment_color_palette.dart';

/// Helper pour générer et gérer les couleurs des appartements dans le calendrier.
///
/// Délègue à [ApartmentColorPalette] pour garantir une palette cohérente sur
/// fond clair.
class CalendarColorHelper {
  static Map<int, Color> generateColorPalette(List<Appartement> appartements) {
    final Map<int, Color> palette = {};
    for (int i = 0; i < appartements.length; i++) {
      final id = appartements[i].id;
      if (id != null) {
        palette[id] = ApartmentColorPalette.colorAt(i);
      }
    }
    return palette;
  }

  static Color getColorForAppartement(
    int appartementId,
    Map<int, Color> palette,
  ) {
    return palette[appartementId] ?? AppColors.textMuted;
  }

  /// Fond légèrement teinté pour un élément lié à un appartement (sur fond blanc).
  static Color getBackgroundColor(Color color) =>
      color.withValues(alpha: 0.15);

  /// Bordure légèrement moins saturée pour un élément lié à un appartement.
  static Color getBorderColor(Color color) => color.withValues(alpha: 0.7);
}
