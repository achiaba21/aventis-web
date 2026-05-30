import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/model/geocoding/geocoding_result.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/service/geocoding/geocoding_service.dart';
import 'package:asfar/widget/map/map_pin_marker.dart';
import 'package:asfar/widget/map/map_search_bar.dart';
import 'package:asfar/widget/map/map_search_suggestions.dart';
import 'package:asfar/widget/map/map_view.dart';
import 'package:asfar/widget/map/map_zone_banner.dart';

/// Composant carte interactif générique (locataire / proprio / démarcheur).
///
/// Pattern Yango/Uber : un marker reste fixe au centre visuel de la carte,
/// l'utilisateur fait glisser la carte sous le marker. Quand il relâche
/// (`MapEventMoveEnd`), debounce 300ms puis `onCenterChanged(LatLng)` au
/// parent — typiquement le parent fait `MapBloc.add(UpdateMapCenter(...))`
/// qui recharge les appartements automatiquement.
///
/// Inclut une `MapSearchBar` en haut (geocoding) et un `MapZoneBanner` en bas
/// ("23 résidences à Cocody Riviera"). Tout est en overlay au-dessus de
/// `MapView` (qui rend les pins prix des résidences).
class InteractiveMapPicker extends StatefulWidget {
  /// Contrôleur optionnel — si null, le widget en crée un interne.
  /// Le parent peut passer un controller pour appeler `move()` programmatiquement
  /// (recentrer sur position user via le FAB, recentrer après search, etc.).
  final MapController? controller;

  final LatLng initialCenter;
  final double initialZoom;
  final List<MapAppartement> appartements;

  /// Bandeau bas — mis à jour à chaque résultat backend.
  final String? zoneName;
  final int resultCount;
  final bool isLoading;

  /// Search bar — état contrôlé par le parent.
  final bool isSearching;
  final String? searchError;

  /// Émis avec debounce 300ms après `MapEventMoveEnd`.
  final void Function(LatLng) onCenterChanged;

  /// Émis au submit de la search bar.
  final void Function(String query) onSearchSubmitted;

  /// Tap sur un marker prix (résidence existante).
  final void Function(MapAppartement)? onMarkerTap;

  const InteractiveMapPicker({
    super.key,
    this.controller,
    required this.initialCenter,
    this.initialZoom = 12,
    required this.appartements,
    this.zoneName,
    required this.resultCount,
    this.isLoading = false,
    this.isSearching = false,
    this.searchError,
    required this.onCenterChanged,
    required this.onSearchSubmitted,
    this.onMarkerTap,
  });

  @override
  State<InteractiveMapPicker> createState() => _InteractiveMapPickerState();
}

class _InteractiveMapPickerState extends State<InteractiveMapPicker> {
  static const _debounceDuration = Duration(milliseconds: 300);

  /// Délai avant de lancer l'autocomplétion de lieu (anti-spam de frappe).
  static const _suggestDebounce = Duration(milliseconds: 350);

  /// Zoom appliqué quand on sélectionne une suggestion.
  static const double _suggestionZoom = 14;

  MapController? _internalCtrl;
  Timer? _debounce;

  final GeocodingService _geocoding = GeocodingService.instance;
  final TextEditingController _searchTextCtrl = TextEditingController();
  Timer? _suggestDebounceTimer;
  List<GeocodingResult> _suggestions = const [];
  int _queryToken = 0;

  MapController get _controller {
    if (widget.controller != null) return widget.controller!;
    return _internalCtrl ??= MapController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _suggestDebounceTimer?.cancel();
    _searchTextCtrl.dispose();
    _internalCtrl?.dispose();
    super.dispose();
  }

  void _onMoveEnd() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      try {
        final center = _controller.camera.center;
        widget.onCenterChanged(center);
      } catch (_) {
        // mapCtrl pas encore prêt — ignore.
      }
    });
  }

  void _onQueryChanged(String value) {
    _suggestDebounceTimer?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      _clearSuggestions();
      return;
    }
    _suggestDebounceTimer = Timer(_suggestDebounce, () => _fetchSuggestions(query));
  }

  Future<void> _fetchSuggestions(String query) async {
    final token = ++_queryToken;
    final results = await _geocoding.autocomplete(query, countrycodes: 'ci');
    // Ignore les réponses obsolètes (l'utilisateur a continué à taper).
    if (!mounted || token != _queryToken) return;
    setState(() => _suggestions = results);
  }

  void _onSuggestionSelected(GeocodingResult result) {
    final target = result.latLng;
    _searchTextCtrl.text = result.displayName.split(',').first.trim();
    _clearSuggestions();
    FocusScope.of(context).unfocus();
    _controller.move(target, _suggestionZoom);
    // `move()` programmatique ne déclenche pas `MapEventMoveEnd` → on notifie
    // manuellement le parent pour recharger les résidences de la zone.
    widget.onCenterChanged(target);
  }

  void _clearSuggestions() {
    _queryToken++;
    if (_suggestions.isNotEmpty) {
      setState(() => _suggestions = const []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        MapView(
          controller: _controller,
          initialCenter: widget.initialCenter,
          initialZoom: widget.initialZoom,
          appartements: widget.appartements,
          onMoveEnd: _onMoveEnd,
          onMarkerTap: widget.onMarkerTap,
        ),
        // Marker fixe au centre visuel (ne bouge pas avec la carte).
        const Align(
          alignment: Alignment.center,
          child: _CenterPin(),
        ),
        // Search bar overlay en haut + suggestions d'autocomplétion.
        Positioned(
          top: 12,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MapSearchBar(
                controller: _searchTextCtrl,
                loading: widget.isSearching,
                error: widget.searchError,
                onChanged: _onQueryChanged,
                onSubmit: (q) {
                  _clearSuggestions();
                  widget.onSearchSubmitted(q);
                },
              ),
              MapSearchSuggestions(
                suggestions: _suggestions,
                onSelected: _onSuggestionSelected,
              ),
            ],
          ),
        ),
        // Bandeau bas — laisse 80px à droite pour le FAB MyLocation.
        Positioned(
          left: 18,
          right: 80,
          bottom: 24 + bottomSafe,
          child: MapZoneBanner(
            count: widget.resultCount,
            zoneName: widget.zoneName,
            isLoading: widget.isLoading,
          ),
        ),
      ],
    );
  }
}

/// Marker central fixe — pin accent or + ombre projetée discrète qui simule
/// un effet "flottant au-dessus de la carte". Privé au composant.
class _CenterPin extends StatelessWidget {
  const _CenterPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const MapPinMarker(),
        const SizedBox(height: 2),
        Container(
          width: 16,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0x55000000),
            borderRadius: BorderRadius.circular(3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
