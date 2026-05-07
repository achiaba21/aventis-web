import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Configuration centralisée pour les maps
/// Définit les tuiles, couleurs et dimensions des composants map
class MapConfig {
  MapConfig._();

  // ==================== TUILES ====================

  /// Clé API Stadia Maps
  static const String _stadiaApiKey = 'd90155af-6b52-49d4-bbf0-1f9f555369a3';

  /// Tuiles Stadia Maps - Style épuré
  static const String lightTileUrl =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png?api_key=$_stadiaApiKey';

  static const String darkTileUrl =
      'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png?api_key=$_stadiaApiKey';

  /// User agent pour les requêtes de tuiles
  static const String userAgent = 'com.asfar.app';

  /// Retourne l'URL des tuiles selon le mode
  static String getTileUrl({bool isDark = true}) {
    return isDark ? darkTileUrl : lightTileUrl;
  }

  // ==================== COULEURS ====================

  /// Couleur du marker normal (gris foncé)
  static const Color markerColor = AppColors.surface;

  /// Couleur du texte sur marker
  static const Color markerTextColor = AppColors.white;

  /// Couleur du marker sélectionné (orange)
  static const Color markerSelectedColor = AppColors.accent;

  /// Couleur de la zone de sélection (orange transparent)
  static const Color zoneColor = Color(0x33FFA02A);

  /// Couleur du contour de zone
  static const Color zoneBorderColor = AppColors.accent;

  /// Couleur du bouton géoloc actif
  static const Color geolocActiveColor = Color(0xFF4A90D9);

  /// Couleur du bouton géoloc inactif
  static const Color geolocInactiveColor = Color(0xFF666666);

  /// Couleur de la position actuelle
  static const Color currentPositionColor = Color(0xFF4A90D9);

  // ==================== DIMENSIONS MARKER ====================

  /// Largeur du marker normal
  static const double markerWidth = 60.0;

  /// Hauteur du marker normal
  static const double markerHeight = 28.0;

  /// Largeur du marker sélectionné
  static const double markerSelectedWidth = 80.0;

  /// Hauteur du marker sélectionné
  static const double markerSelectedHeight = 44.0;

  /// Taille du cluster
  static const double clusterSize = 44.0;

  /// Border radius du marker (pilule)
  static const double markerBorderRadius = 14.0;

  /// Taille de la flèche du marker
  static const double markerArrowSize = 8.0;

  // ==================== DIMENSIONS FAB ====================

  /// Taille du FAB géolocalisation
  static const double fabSize = 48.0;

  /// Marge du FAB
  static const double fabMargin = 16.0;

  // ==================== ZOOM ====================

  /// Zoom par défaut
  static const double defaultZoom = 13.0;

  /// Zoom sur position utilisateur
  static const double userPositionZoom = 15.0;

  /// Zoom sur résidence sélectionnée
  static const double selectedZoom = 16.0;

  /// Zoom sur quartier (fallback)
  static const double neighborhoodZoom = 14.0;

  // ==================== ZONE SELECTOR ====================

  /// Rayon minimum de zone (km)
  static const double minZoneRadius = 0.5;

  /// Rayon maximum de zone (km)
  static const double maxZoneRadius = 5.0;

  /// Rayon par défaut de zone (km)
  static const double defaultZoneRadius = 2.0;

  /// Hauteur du bottom sheet
  static const double zoneSelectorHeight = 280.0;

  /// Taille initiale du bottom sheet détails (ratio écran)
  static const double detailsSheetInitialSize = 0.4;

  /// Taille minimum du bottom sheet détails (ratio écran)
  static const double detailsSheetMinSize = 0.2;

  /// Taille maximum du bottom sheet détails (ratio écran)
  static const double detailsSheetMaxSize = 0.8;

  // ==================== ANIMATIONS ====================

  /// Durée animation marker tap
  static const Duration markerTapDuration = Duration(milliseconds: 200);

  /// Durée animation marker select
  static const Duration markerSelectDuration = Duration(milliseconds: 300);

  /// Durée animation pulse
  static const Duration pulseDuration = Duration(milliseconds: 1000);

  /// Durée animation bottom sheet
  static const Duration bottomSheetDuration = Duration(milliseconds: 300);

  // ==================== OMBRES ====================

  /// Ombre du marker
  static List<BoxShadow> get markerShadow => [
        BoxShadow(
          color: AppColors.textPrimary.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Ombre du marker sélectionné
  static List<BoxShadow> get markerSelectedShadow => [
        BoxShadow(
          color: markerSelectedColor.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  /// Ombre du FAB
  static List<BoxShadow> get fabShadow => [
        BoxShadow(
          color: AppColors.textPrimary.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
