import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_bloc.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_event.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_state.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/demarcheur/listings/listing_filters.dart';
import 'package:asfar/screen/client/locataire/map/widget/my_location_fab.dart';
import 'package:asfar/util/calc/listing_map_filter.dart';
import 'package:asfar/util/location_util.dart';
import 'package:asfar/widget/map/interactive_map_picker.dart';
import 'package:asfar/widget/map/overlay/map_empty_overlay.dart';
import 'package:asfar/widget/map/overlay/map_error_overlay.dart';
import 'package:asfar/widget/map/overlay/map_loading_overlay.dart';

/// Carte interactive démarcheur — parité UX avec `LocataireMapScreen`.
///
/// Compose `InteractiveMapPicker` (Yango + search bar + bandeau zone) + les
/// 3 overlays mutualisés + `MyLocationFab`. Le `DemarcheurMapBloc` est fourni
/// par le parent via `BlocProvider`.
///
/// Filtrage local : `activeFilters` (issus de la vue liste) sont ré-appliqués
/// en post-fetch sur les `MapAppartement` retournés par le backend via
/// jointure id ↔ `appartementsParId`. Évite tout filtrage côté serveur sur
/// `proprietaireId` / `typeLocation` / `communeNom` (absents de `MapAppartement`).
///
/// Tap pin → callback `onTapAppartement(Appartement)` qui navigue vers le
/// détail (pas de bottom sheet preview, contrairement au locataire).
class ListingMapPane extends StatefulWidget {
  final Map<int, Appartement> appartementsParId;
  final ListingFilters activeFilters;
  final ValueChanged<Appartement> onTapAppartement;
  final LatLng? initialCenter;

  const ListingMapPane({
    super.key,
    required this.appartementsParId,
    required this.activeFilters,
    required this.onTapAppartement,
    this.initialCenter,
  });

  @override
  State<ListingMapPane> createState() => _ListingMapPaneState();
}

class _ListingMapPaneState extends State<ListingMapPane> {
  static const _abidjanFallback = LatLng(5.345, -4.024);
  static const _defaultRadiusKm = 10.0;
  static const _initialZoom = 12.0;
  static const _userZoom = 14.0;

  late final MapController _mapCtrl;
  late LatLng _currentCenter;
  bool _locatingUser = false;
  bool _emptyOverlayDismissed = false;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    _currentCenter = widget.initialCenter ?? _abidjanFallback;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadInZone(_currentCenter);
    });
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  void _loadInZone(LatLng center) {
    _currentCenter = center;
    _emptyOverlayDismissed = false;
    context.read<DemarcheurMapBloc>().add(
          LoadDemarcheurMapAppartements(
            center: center,
            radiusKm: _defaultRadiusKm,
          ),
        );
  }

  void _onCenterChanged(LatLng latLng) {
    _currentCenter = latLng;
    _emptyOverlayDismissed = false;
    context.read<DemarcheurMapBloc>().add(UpdateDemarcheurMapCenter(latLng));
  }

  void _onSearchSubmitted(String query) {
    context.read<DemarcheurMapBloc>().add(SearchPlaceDemarcheur(query));
  }

  Future<void> _onLocateMe() async {
    setState(() => _locatingUser = true);
    final messenger = ScaffoldMessenger.of(context);
    final latLng = await LocationUtil.getCurrentLatLng();
    if (!mounted) return;
    setState(() => _locatingUser = false);
    if (latLng == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
              'Activez la géolocalisation dans les paramètres pour utiliser cette fonction.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    _currentCenter = latLng;
    _mapCtrl.move(latLng, _userZoom);
    _loadInZone(latLng);
  }

  void _onPlaceSearchSuccess(DemarcheurMapPlaceSearchSuccess state) {
    final pos = state.result.position;
    _currentCenter = pos;
    _mapCtrl.move(pos, _userZoom);
    // Le moveEnd qui s'ensuit déclenche UpdateDemarcheurMapCenter via le picker.
  }

  void _onMarkerTap(MapAppartement m) {
    final id = m.id;
    if (id == null) return;
    final appart = widget.appartementsParId[id];
    if (appart == null) return;
    widget.onTapAppartement(appart);
  }

  List<MapAppartement> _extractAppartements(DemarcheurMapState state) {
    if (state is DemarcheurMapAppartementsLoaded) return state.appartements;
    return const [];
  }

  String? _extractZoneName(DemarcheurMapState state) {
    if (state is DemarcheurMapAppartementsLoaded) return state.zoneName;
    if (state is DemarcheurMapEmpty) return state.zoneName;
    return null;
  }

  bool _isEmptyState(DemarcheurMapState state, List<MapAppartement> filtered) {
    if (state is DemarcheurMapEmpty) return true;
    if (state is DemarcheurMapAppartementsLoaded && filtered.isEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DemarcheurMapBloc, DemarcheurMapState>(
      listenWhen: (_, current) => current is DemarcheurMapPlaceSearchSuccess,
      listener: (context, state) {
        if (state is DemarcheurMapPlaceSearchSuccess) {
          _onPlaceSearchSuccess(state);
        }
      },
      builder: (context, state) {
        final raw = _extractAppartements(state);
        final filtered = ListingMapFilter.apply(
          source: raw,
          appartementsParId: widget.appartementsParId,
          filters: widget.activeFilters,
        );
        final zoneName = _extractZoneName(state);
        final isLoading = state is DemarcheurMapLoading;
        final isSearching = state is DemarcheurMapPlaceSearchLoading;
        final searchError =
            state is DemarcheurMapPlaceSearchError ? state.message : null;
        final errorMessage =
            state is DemarcheurMapError ? state.message : null;
        final isEmpty = !isLoading &&
            errorMessage == null &&
            !_emptyOverlayDismissed &&
            _isEmptyState(state, filtered);

        return Stack(
          children: [
            InteractiveMapPicker(
              controller: _mapCtrl,
              initialCenter: _currentCenter,
              initialZoom: _initialZoom,
              appartements: filtered,
              zoneName: zoneName,
              resultCount: filtered.length,
              isLoading: isLoading,
              isSearching: isSearching,
              searchError: searchError,
              onCenterChanged: _onCenterChanged,
              onSearchSubmitted: _onSearchSubmitted,
              onMarkerTap: _onMarkerTap,
            ),
            if (isLoading) const MapLoadingOverlay(),
            if (errorMessage != null)
              MapErrorOverlay(
                message: errorMessage,
                onRetry: () => _loadInZone(_currentCenter),
              ),
            if (isEmpty)
              MapEmptyOverlay(
                title: 'Aucun logement partenaire ici',
                subtitle:
                    'Déplacez la carte ou ajustez vos filtres pour les voir.',
                onDismiss: () =>
                    setState(() => _emptyOverlayDismissed = true),
              ),
            Positioned(
              right: 18,
              bottom: 24,
              child: MyLocationFab(
                onTap: _onLocateMe,
                loading: _locatingUser,
              ),
            ),
          ],
        );
      },
    );
  }
}
