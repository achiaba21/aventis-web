import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/osm_dark_matrix.dart';

/// Mini-carte non-interactive pour la section "Localisation" du
/// `LocataireDetailScreen` — V9.7c.
///
/// Tuiles OSM filtrées en thème dark via `tileBuilder` + `ColorFiltered`
/// (matrice `osmDarkMatrix` partagée avec `MapView` V9.7). 1 marker accent
/// or centré sur la position. Interactions désactivées : le widget est
/// purement visuel, le pan/zoom est réservé à `LocataireMapScreen`.
class MiniMapPreview extends StatelessWidget {
  final LatLng center;
  final double zoom;
  final double height;

  const MiniMapPreview({
    super.key,
    required this.center,
    this.zoom = 15.0,
    this.height = 180,
  });

  static const _osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: zoom,
            minZoom: 4,
            maxZoom: 18,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: _osmUrl,
              userAgentPackageName: 'com.asfar.app',
              tileBuilder: (context, tileWidget, tile) {
                return ColorFiltered(
                  colorFilter: const ColorFilter.matrix(osmDarkMatrix),
                  child: tileWidget,
                );
              },
            ),
            MarkerLayer(
              rotate: false,
              markers: [
                Marker(
                  point: center,
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  child: const _MiniPinMarker(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pin pour la mini-carte : cercle accent or avec halo.
class _MiniPinMarker extends StatelessWidget {
  const _MiniPinMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.onAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
