import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/config/map_config.dart';
import 'package:asfar/util/city_coordinates.dart';
import 'package:asfar/widget/map/map_style_layer.dart';
import 'package:asfar/widget/sensitive/sensitive_data_placeholder.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget de base générique pour afficher une localisation sur une carte
/// Gère 3 cas :
/// - Localisation exacte (avec marker)
/// - Localisation approximative (zone floue, sans marker)
/// - Pas de localisation (placeholder)
///
/// Utilisé par ResidenceMapSection et AppartMapSection
class BaseLocationMap extends StatelessWidget {
  const BaseLocationMap({
    super.key,
    this.exactLocation,
    this.fallbackLocation,
    this.locationName,
    this.isOwner = false,
    this.showExactLocation = false,
    this.onEditLocation,
    this.onMaskedTap,
    this.height = 200,
  });

  /// Coordonnées exactes (si disponibles)
  final LatLng? exactLocation;

  /// Coordonnées approximatives (ville/quartier)
  final LatLng? fallbackLocation;

  /// Nom à afficher (ex: "Cocody, Abidjan")
  final String? locationName;

  /// true = propriétaire, false = locataire
  final bool isOwner;

  /// true = montrer la localisation exacte (après paiement)
  final bool showExactLocation;

  /// Callback pour éditer la localisation (proprio uniquement)
  final VoidCallback? onEditLocation;

  /// Callback quand l'utilisateur tape sur la zone masquée
  final VoidCallback? onMaskedTap;

  /// Hauteur de la carte
  final double height;

  @override
  Widget build(BuildContext context) {
    // Cas 1: Coordonnées exactes + autorisé à voir
    if (exactLocation != null && (isOwner || showExactLocation)) {
      return _buildExactMap(exactLocation!, showEditButton: isOwner);
    }

    // Cas 2: Proprio sans coordonnées → Placeholder "Ajouter"
    if (isOwner && exactLocation == null) {
      return _buildOwnerPlaceholder();
    }

    // Cas 3: Localisation approximative (locataire avant paiement)
    if (fallbackLocation != null) {
      return _buildFallbackMap(fallbackLocation!, locationName ?? "");
    }

    // Cas 4: Aucune localisation
    return SensitiveDataPlaceholder.location(onTap: onMaskedTap);
  }

  /// Construit la carte avec le marker exact
  Widget _buildExactMap(LatLng location, {bool showEditButton = false}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: location,
                initialZoom: MapConfig.userPositionZoom,
              ),
              children: [
                const MapStyleLayer(isDarkMode: true),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: location,
                      width: 32,
                      height: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: MapConfig.markerSelectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 3),
                          boxShadow: MapConfig.markerSelectedShadow,
                        ),
                        child: const Icon(
                          Icons.home,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Overlay avec nom de lieu
            if (locationName != null && locationName!.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.textPrimary.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextSeed(
                          locationName!,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // FAB Modifier (proprio uniquement)
            if (showEditButton && onEditLocation != null)
              Positioned(
                bottom: locationName != null ? 48 : 12,
                right: 12,
                child: GestureDetector(
                  onTap: onEditLocation,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      boxShadow: MapConfig.fabShadow,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Construit le placeholder pour le proprio quand aucune localisation n'est définie
  Widget _buildOwnerPlaceholder() {
    return GestureDetector(
      onTap: onEditLocation,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              TextSeed(
                "Localisation non renseignée",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              TextSeed(
                "Appuyez pour ajouter",
                fontSize: 12,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit la carte centrée sur la ville/commune (sans marker précis)
  /// Affiche "Localisation approximative" pour les locataires
  Widget _buildFallbackMap(LatLng location, String name) {
    return GestureDetector(
      onTap: onMaskedTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.accent.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Carte sans marker
              FlutterMap(
                options: MapOptions(
                  initialCenter: location,
                  initialZoom: CityCoordinates.neighborhoodZoom,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: const [
                  MapStyleLayer(isDarkMode: true),
                ],
              ),

              // Overlay semi-transparent
              Container(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.3),
                ),
              ),

              // Message au centre
              Center(
                child: Container(
                  margin: EdgeInsets.all(Espacement.paddingBloc),
                  padding: EdgeInsets.all(Espacement.paddingBloc),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.accent,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      if (name.isNotEmpty)
                        TextSeed(
                          name,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 4),
                      TextSeed(
                        "Localisation approximative",
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
