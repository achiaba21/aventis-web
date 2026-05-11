import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/model/map/map_residence.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_price_marker.dart';

/// Wrapper `FlutterMap` configuré pour Asfar Premium dark.
///
/// Tuiles OSM standard transformées en dark via `tileBuilder` qui applique
/// un `ColorFiltered` UNIQUEMENT sur les tuiles (les markers accent or
/// gardent leur couleur native). Pas de dépendance externe ni clé API.
///
/// Émet `onMoveEnd` après que l'utilisateur a relâché la carte (utilisé
/// pour afficher le bouton "Rechercher dans cette zone").
class MapView extends StatelessWidget {
  final MapController controller;
  final LatLng initialCenter;
  final double initialZoom;
  final List<MapResidence> residences;
  final VoidCallback? onMoveEnd;
  final void Function(MapResidence residence)? onMarkerTap;

  const MapView({
    super.key,
    required this.controller,
    required this.initialCenter,
    required this.residences,
    this.initialZoom = 12,
    this.onMoveEnd,
    this.onMarkerTap,
  });

  /// Matrice invert + désaturation pour passer les tuiles OSM (light) en
  /// thème dark cohérent avec Asfar Premium. Coût GPU négligeable.
  static const List<double> _darkenMatrix = <double>[
    -0.85, -0.10, -0.10, 0, 255,
    -0.10, -0.85, -0.10, 0, 255,
    -0.10, -0.10, -0.85, 0, 255,
        0,    0,    0, 1,   0,
  ];

  static const _osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  List<Marker> _buildMarkers() {
    return residences
        .where((r) => r.displayLat != null && r.displayLongi != null)
        .map((r) {
      return Marker(
        point: r.displayPosition,
        width: 60,
        height: 32,
        alignment: Alignment.center,
        child: MapPriceMarker(
          price: (r.minPrice ?? 0).round(),
          onTap: onMarkerTap == null ? null : () => onMarkerTap!(r),
        ),
      );
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: 4,
        maxZoom: 18,
        onMapEvent: (event) {
          if (event is MapEventMoveEnd ||
              event is MapEventFlingAnimationEnd ||
              event is MapEventDoubleTapZoomEnd) {
            onMoveEnd?.call();
          }
        },
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.doubleTapZoom |
              InteractiveFlag.flingAnimation,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _osmUrl,
          userAgentPackageName: 'com.asfar.app',
          tileBuilder: (context, tileWidget, tile) {
            return ColorFiltered(
              colorFilter: const ColorFilter.matrix(_darkenMatrix),
              child: tileWidget,
            );
          },
        ),
        MarkerLayer(
          markers: _buildMarkers(),
          rotate: false,
        ),
      ],
    );
  }
}
