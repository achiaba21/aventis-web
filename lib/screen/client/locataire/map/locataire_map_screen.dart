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
import 'package:asfar/screen/client/locataire/map/widget/map_marker_bottom_sheet.dart';
import 'package:asfar/screen/client/locataire/map/widget/my_location_fab.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/location_util.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/map/interactive_map_picker.dart';
import 'package:asfar/widget/map/overlay/map_empty_overlay.dart';
import 'package:asfar/widget/map/overlay/map_error_overlay.dart';
import 'package:asfar/widget/map/overlay/map_loading_overlay.dart';

/// Écran cartographique interactif du locataire — V9.7b + InteractiveMapPicker.
///
/// Consomme `MapBloc` via `LoadFilteredMapAppartements(center)` au init puis
/// `UpdateMapCenter` à chaque déplacement de la carte (pattern Yango via
/// `InteractiveMapPicker` — marker fixe au centre, carte qui glisse dessous).
/// La search bar du picker déclenche `SearchPlace` ; au succès, recentrage
/// programmatique via `_mapCtrl.move` qui réenclenche le cycle moveEnd → reload.
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
    context.read<MapBloc>().add(
          LoadFilteredMapAppartements(
            center: center,
            radiusKm: _defaultRadiusKm,
          ),
        );
  }

  void _onCenterChanged(LatLng latLng) {
    _currentCenter = latLng;
    _emptyOverlayDismissed = false;
    context.read<MapBloc>().add(UpdateMapCenter(latLng));
  }

  void _onSearchSubmitted(String query) {
    context.read<MapBloc>().add(SearchPlace(query));
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
    // Le move déclenche un MapEventMoveEnd → InteractiveMapPicker debounce →
    // onCenterChanged → UpdateMapCenter. Le call explicite garantit un load
    // immédiat sans attendre le debounce.
    _loadInZone(latLng);
  }

  void _onMarkerTap(MapAppartement mapAppart) {
    MapMarkerBottomSheet.show(
      context,
      appartement: mapAppart,
      onViewDetails: (Appartement? loaded) {
        Navigator.of(context).pop();
        final toPush = loaded ??
            Appartement(
              id: mapAppart.id,
              titre: mapAppart.title,
              prix: mapAppart.price?.toDouble(),
              imgUrl: mapAppart.imgUrl,
            );
        pushScreen(context, LocataireDetailScreen(appartement: toPush));
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

  String? _extractZoneName(MapState state) {
    if (state is MapAppartementsLoaded) return state.zoneName;
    if (state is MapEmpty) return state.zoneName;
    return null;
  }

  bool _isEmptyState(MapState state, List<MapAppartement> appartements) {
    if (state is MapEmpty) return true;
    if (state is MapAppartementsLoaded && appartements.isEmpty) return true;
    return false;
  }

  void _onPlaceSearchSuccess(MapPlaceSearchSuccess state) {
    final pos = state.result.position;
    _currentCenter = pos;
    _mapCtrl.move(pos, _userZoom);
    // Le moveEnd qui s'ensuit déclenchera UpdateMapCenter via le picker.
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
      body: BlocConsumer<MapBloc, MapState>(
        listenWhen: (_, current) => current is MapPlaceSearchSuccess,
        listener: (context, state) {
          if (state is MapPlaceSearchSuccess) {
            _onPlaceSearchSuccess(state);
          }
        },
        builder: (context, state) {
          final appartements = _extractAppartements(state);
          final zoneName = _extractZoneName(state);
          final isLoading = state is MapLoading;
          final isSearching = state is MapPlaceSearchLoading;
          final searchError =
              state is MapPlaceSearchError ? state.message : null;
          final errorMessage = state is MapError ? state.message : null;
          final isEmpty = !isLoading &&
              errorMessage == null &&
              !_emptyOverlayDismissed &&
              _isEmptyState(state, appartements);

          return Stack(
            children: [
              InteractiveMapPicker(
                controller: _mapCtrl,
                initialCenter: _currentCenter,
                initialZoom: _initialZoom,
                appartements: appartements,
                zoneName: zoneName,
                resultCount: appartements.length,
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
