import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/map_bloc/map_bloc.dart';
import 'package:asfar/bloc/map_bloc/map_event.dart';
import 'package:asfar/bloc/map_bloc/map_state.dart';
import 'package:asfar/model/map/map_residence.dart';
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
import 'package:asfar/util/mapping/map_residence_to_listing.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran cartographique interactif du locataire — V9.7.
///
/// Consomme `MapBloc` via `LoadFilteredMapResidences(center, radius)`.
/// Centre par défaut Abidjan (fallback si géoloc indisponible/refusée).
/// FAB "Ma position" demande la permission au tap, recentre sur position
/// user. Bouton "Rechercher dans cette zone" apparaît après pan/zoom.
/// Tap marker → bottom sheet preview → push détail.
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
  bool _showSearchInArea = false;
  bool _locatingUser = false;
  bool _firstLoadDone = false;

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
    context.read<MapBloc>().add(
          LoadFilteredMapResidences(
            center: center,
            radiusKm: _defaultRadiusKm,
          ),
        );
    _firstLoadDone = true;
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
    if (!_showSearchInArea) {
      setState(() => _showSearchInArea = true);
    }
  }

  void _onSearchInArea() {
    setState(() => _showSearchInArea = false);
    _loadInZone(_currentCenter);
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

  void _onMarkerTap(MapResidence residence) {
    MapMarkerBottomSheet.show(
      context,
      residence: residence,
      onViewDetails: () {
        Navigator.of(context).pop();
        final listing = MapResidenceToListingMapper.mapOne(residence);
        pushScreen(context, LocataireDetailScreen(listing: listing));
      },
    );
  }

  void _onOpenFilters() {
    pushScreen(context, const LocataireSearchScreen());
  }

  List<MapResidence> _extractResidences(MapState state) {
    if (state is MapResidencesLoaded) return state.residences;
    if (state is MapResidenceSelected) {
      return state.allResidences ?? const [];
    }
    return const [];
  }

  bool _isEmptyState(MapState state, List<MapResidence> residences) {
    if (state is MapEmpty) return true;
    if (state is MapResidencesLoaded && residences.isEmpty) return true;
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
          final residences = _extractResidences(state);
          final isLoading = state is MapLoading;
          final errorMessage = state is MapError ? state.message : null;
          final isEmpty = !isLoading &&
              errorMessage == null &&
              _isEmptyState(state, residences);

          return Stack(
            children: [
              MapView(
                controller: _mapCtrl,
                initialCenter: _currentCenter,
                initialZoom: _initialZoom,
                residences: residences,
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
                  onExpandRadius: () => _loadInZone(_currentCenter),
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
