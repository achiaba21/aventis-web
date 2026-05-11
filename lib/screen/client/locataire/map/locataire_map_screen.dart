import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/map_bloc/map_bloc.dart';
import 'package:asfar/bloc/map_bloc/map_event.dart';
import 'package:asfar/bloc/map_bloc/map_state.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/screen/client/locataire/home/search_screen.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_empty_overlay.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_error_overlay.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_loading_overlay.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_marker_bottom_sheet.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_view.dart';
import 'package:asfar/screen/client/locataire/map/widget/my_location_fab.dart';
import 'package:asfar/screen/client/locataire/map/widget/search_in_area_button.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/location_util.dart';
import 'package:asfar/util/mapping/appartement_to_listing.dart';
import 'package:asfar/util/mapping/map_appartement_to_listing.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/card/listing_preview.dart';

/// Écran cartographique interactif du locataire — V9.7b.
///
/// Consomme `MapBloc` via `LoadFilteredMapAppartements(center, radius)`.
/// 1 marker = 1 appartement. Coordonnées toujours obfusquées en browse.
/// Centre par défaut Abidjan (fallback si géoloc indisponible/refusée).
/// FAB "Ma position" demande la permission au tap, recentre sur position
/// user. Bouton "Rechercher dans cette zone" apparaît après pan/zoom.
/// Tap marker → bottom sheet preview (photo lazy) → push détail direct.
class LocataireMapScreen extends StatefulWidget {
  /// Centre initial optionnel. Si null, charge la position user
  /// (avec fallback Abidjan).
  final LatLng? initialCenter;

  const LocataireMapScreen({super.key, this.initialCenter});

  @override
  State<LocataireMapScreen> createState() => _LocataireMapScreenState();
}

class _LocataireMapScreenState extends State<LocataireMapScreen> {
  static const _abidjanFallback = LatLng(5.345, -4.024);
  static const _defaultRadiusKm = 10.0;
  static const _maxRadiusKm = 200.0;
  static const _initialZoom = 12.0;
  static const _userZoom = 14.0;

  late final MapController _mapCtrl;
  late LatLng _currentCenter;
  double _currentRadiusKm = _defaultRadiusKm;
  bool _showSearchInArea = false;
  bool _locatingUser = false;
  bool _firstLoadDone = false;
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

  void _loadInZone(LatLng center, {double? radiusKm}) {
    final radius = radiusKm ?? _currentRadiusKm;
    _currentRadiusKm = radius;
    context.read<MapBloc>().add(
          LoadFilteredMapAppartements(
            center: center,
            radiusKm: radius,
          ),
        );
    _firstLoadDone = true;
    _emptyOverlayDismissed = false;
  }

  /// Calcule le rayon en km couvrant la zone actuellement visible
  /// (centre → coin nord-est). Permet au dézoom d'élargir la recherche.
  double _radiusFromVisibleBounds() {
    try {
      final camera = _mapCtrl.camera;
      final bounds = camera.visibleBounds;
      const distance = Distance();
      final corner = LatLng(bounds.north, bounds.east);
      final km = distance.as(LengthUnit.Kilometer, camera.center, corner);
      return km.clamp(1.0, _maxRadiusKm).toDouble();
    } catch (_) {
      return _defaultRadiusKm;
    }
  }

  void _onMoveEnd() {
    if (!_firstLoadDone) return;
    try {
      final camera = _mapCtrl.camera;
      _currentCenter = camera.center;
    } catch (_) {
      // mapCtrl pas encore prêt — ignore.
      return;
    }
    // Dès le premier mouvement utilisateur, l'overlay empty (s'il est
    // affiché) doit céder la place pour permettre l'exploration.
    final dismiss = !_emptyOverlayDismissed;
    if (!_showSearchInArea || dismiss) {
      setState(() {
        _showSearchInArea = true;
        if (dismiss) _emptyOverlayDismissed = true;
      });
    }
  }

  void _onSearchInArea() {
    setState(() => _showSearchInArea = false);
    _loadInZone(_currentCenter, radiusKm: _radiusFromVisibleBounds());
  }

  void _onExpandRadius() {
    final next = (_currentRadiusKm * 2).clamp(_defaultRadiusKm, _maxRadiusKm);
    _loadInZone(_currentCenter, radiusKm: next.toDouble());
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

  void _onMarkerTap(MapAppartement appartement) {
    MapMarkerBottomSheet.show(
      context,
      appartement: appartement,
      onViewDetails: (Appartement? loaded) {
        Navigator.of(context).pop();
        final ListingPreview listing = loaded != null
            ? AppartementToListingMapper.mapOne(loaded)
            : MapAppartementToListingMapper.mapOne(appartement);
        pushScreen(context, LocataireDetailScreen(listing: listing));
      },
    );
  }

  void _onOpenFilters() {
    pushScreen(context, const LocataireSearchScreen());
  }

  List<MapAppartement> _extractAppartements(MapState state) {
    if (state is MapAppartementsLoaded) return state.appartements;
    if (state is MapAppartementSelected) {
      return state.allAppartements ?? const [];
    }
    return const [];
  }

  bool _isEmptyState(MapState state, List<MapAppartement> appartements) {
    if (state is MapEmpty) return true;
    if (state is MapAppartementsLoaded && appartements.isEmpty) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Carte',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
        trailing: IconBoutton(
          icon: Icons.tune,
          onPressed: _onOpenFilters,
        ),
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final appartements = _extractAppartements(state);
          final isLoading = state is MapLoading;
          final errorMessage = state is MapError ? state.message : null;
          final isEmpty = !isLoading &&
              errorMessage == null &&
              !_emptyOverlayDismissed &&
              _isEmptyState(state, appartements);

          return Stack(
            children: [
              MapView(
                controller: _mapCtrl,
                initialCenter: _currentCenter,
                initialZoom: _initialZoom,
                appartements: appartements,
                onMoveEnd: _onMoveEnd,
                onMarkerTap: _onMarkerTap,
              ),
              Positioned(
                top: 12,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SearchInAreaButton(
                    visible: _showSearchInArea,
                    onTap: _onSearchInArea,
                  ),
                ),
              ),
              if (isLoading) const MapLoadingOverlay(),
              if (errorMessage != null)
                MapErrorOverlay(
                  message: errorMessage,
                  onRetry: () => _loadInZone(_currentCenter),
                ),
              if (isEmpty)
                MapEmptyOverlay(
                  onExpandRadius: _currentRadiusKm < _maxRadiusKm
                      ? _onExpandRadius
                      : null,
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
      ),
    );
  }
}
