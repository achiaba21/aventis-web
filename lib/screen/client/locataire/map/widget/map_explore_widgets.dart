import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:asfar/config/map_config.dart';
import 'package:asfar/model/map/map_residence.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/map/custom_map_marker.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Carte d'information pour la bottom sheet des détails résidence
class MapInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const MapInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 6),
              TextSeed(
                title,
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextSeed(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

/// Marqueur de position actuelle de l'utilisateur
class CurrentPositionMarker extends StatelessWidget {
  const CurrentPositionMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: MapConfig.currentPositionColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: MapConfig.currentPositionColor.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

/// Builder de marqueurs pour les résidences sur la carte
class ResidenceMarkersBuilder {
  final List<MapResidence> residences;
  final int? selectedResidenceId;
  final void Function(MapResidence) onResidenceTapped;

  ResidenceMarkersBuilder({
    required this.residences,
    this.selectedResidenceId,
    required this.onResidenceTapped,
  });

  List<Marker> build() {
    return residences.map((residence) {
      if (!residence.hasValidDisplayCoordinates) return null;

      final isSelected = selectedResidenceId == residence.id;

      return Marker(
        point: residence.displayPosition,
        width: isSelected ? MapConfig.markerSelectedWidth : MapConfig.markerWidth,
        height: isSelected
            ? MapConfig.markerSelectedHeight + MapConfig.markerArrowSize
            : MapConfig.markerHeight + MapConfig.markerArrowSize,
        child: CustomMapMarker(
          price: residence.minPrice?.toInt(),
          isSelected: isSelected,
          onTap: () => onResidenceTapped(residence),
        ),
      );
    }).where((marker) => marker != null).cast<Marker>().toList();
  }
}
