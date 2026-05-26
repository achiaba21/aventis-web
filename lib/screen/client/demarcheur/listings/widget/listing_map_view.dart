import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/widget/map/map_view.dart';

/// Adaptateur de [MapView] (carte FlutterMap réutilisée du module locataire)
/// pour afficher les logements partenaires d'un démarcheur.
///
/// Convertit `Appartement` (modèle métier) → `MapAppartement` (modèle map)
/// pour réutiliser intégralement la carte dark theme + markers prix sans
/// dupliquer la configuration FlutterMap (tuiles OSM dark, interactions,
/// markers).
class ListingMapView extends StatefulWidget {
  final List<Appartement> appartements;
  final void Function(Appartement) onTap;

  const ListingMapView({
    super.key,
    required this.appartements,
    required this.onTap,
  });

  @override
  State<ListingMapView> createState() => _ListingMapViewState();
}

class _ListingMapViewState extends State<ListingMapView> {
  static const _abidjanFallback = LatLng(5.345, -4.024);
  late final MapController _mapCtrl;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  List<MapAppartement> get _mappable => widget.appartements
      .where((a) => a.lat != null && a.lon != null && a.id != null)
      .map(_toMapAppartement)
      .toList(growable: false);

  MapAppartement _toMapAppartement(Appartement a) => MapAppartement(
        id: a.id,
        title: a.titre,
        displayLat: a.lat,
        displayLongi: a.lon,
        price: a.priceAmount,
        communeName: a.communeNom,
      );

  LatLng get _initialCenter {
    final mappable = _mappable;
    if (mappable.isNotEmpty) return mappable.first.displayPosition;
    return _abidjanFallback;
  }

  void _onMarkerTap(MapAppartement m) {
    final original = widget.appartements.firstWhere(
      (a) => a.id == m.id,
      orElse: () => widget.appartements.first,
    );
    widget.onTap(original);
  }

  @override
  Widget build(BuildContext context) {
    return MapView(
      controller: _mapCtrl,
      initialCenter: _initialCenter,
      appartements: _mappable,
      onMarkerTap: _onMarkerTap,
    );
  }
}
