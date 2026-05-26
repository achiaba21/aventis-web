import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/util/osm_dark_matrix.dart';
import 'package:asfar/widget/map/map_price_pin.dart';

/// Wrapper `FlutterMap` générique configuré pour Asfar Premium dark.
///
/// Tuiles OSM standard transformées en dark via `tileBuilder` qui applique
/// un `ColorFiltered` UNIQUEMENT sur les tuiles (les markers accent or
/// gardent leur couleur native). Pas de dépendance externe ni clé API.
///
/// Émet `onMoveEnd` après que l'utilisateur a relâché la carte (utilisé
/// pour afficher le bouton "Rechercher dans cette zone").
///
/// Widget partagé entre tous les modules ayant besoin d'afficher des
/// logements sur une carte (locataire, démarcheur, proprio).
class MapView extends StatelessWidget {
  final MapController controller;
  final LatLng initialCenter;
  final double initialZoom;
  final List<MapAppartement> appartements;
  final VoidCallback? onMoveEnd;
  final void Function(MapAppartement appartement)? onMarkerTap;

  const MapView({
    super.key,
    required this.controller,
    required this.initialCenter,
    required this.appartements,
    this.initialZoom = 12,
    this.onMoveEnd,
    this.onMarkerTap,
  });

  static const _osmUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  List<Marker> _buildMarkers() {
    return appartements
        .where((a) => a.displayLat != null && a.displayLongi != null)
        .map((a) {
      return Marker(
        point: a.displayPosition,
        width: 60,
        height: 32,
        alignment: Alignment.center,
        child: MapPricePin(
          price: a.price ?? 0,
          onTap: onMarkerTap == null ? null : () => onMarkerTap!(a),
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
              colorFilter: const ColorFilter.matrix(osmDarkMatrix),
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
