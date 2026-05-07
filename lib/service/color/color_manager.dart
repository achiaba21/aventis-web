import 'package:flutter/material.dart';
import 'package:asfar/theme/palettes/apartment_color_palette.dart';

/// Service Singleton pour gérer les couleurs des appartements durant la session.
///
/// Attribue une couleur déterministe (basée sur l'id) à chaque appartement et
/// la conserve en mémoire pour garantir la cohérence visuelle durant la session.
///
/// RÈGLES:
/// - Une couleur unique par appartement (déterministe via son id)
/// - Palette adaptée au fond clair ([ApartmentColorPalette])
/// - Persistance en mémoire uniquement (pas de stockage local)
/// - Nettoyage au logout via [clearColors]
class ColorManager {
  ColorManager._();

  static final ColorManager instance = ColorManager._();

  final Map<int, Color> _apartmentColors = {};

  Color getColorForApartment(int appartementId) {
    return _apartmentColors.putIfAbsent(
      appartementId,
      () => ApartmentColorPalette.colorForId(appartementId),
    );
  }

  void clearColors() {
    _apartmentColors.clear();
  }

  int get cachedColorsCount => _apartmentColors.length;

  bool hasColorFor(int appartementId) {
    return _apartmentColors.containsKey(appartementId);
  }

  Map<int, Color> get allColors => Map.unmodifiable(_apartmentColors);
}
