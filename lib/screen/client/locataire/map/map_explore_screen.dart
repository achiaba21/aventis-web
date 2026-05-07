import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/config/map_config.dart';
import 'package:asfar/model/map/map_residence.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/home/owner_appartements_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/loader/circular_progress.dart';
import 'package:asfar/screen/client/locataire/map/widget/map_explore_widgets.dart';
import 'package:asfar/widget/map/location_button.dart';
import 'package:asfar/widget/map/map_style_layer.dart';
import 'package:asfar/widget/map/zone_selector.dart';
import 'package:asfar/widget/text/text_seed.dart';

class MapExploreScreen extends StatefulWidget {
  const MapExploreScreen({super.key});

  @override
  State<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends State<MapExploreScreen> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  LocationButtonState _locationButtonState = LocationButtonState.inactive;

  // Résidences filtrées pour la carte
  List<MapResidence> _mapResidences = [];

  // Zone selection
  bool _isZoneModeActive = false;
  LatLng? _zoneCenter;
  double _zoneRadius = MapConfig.defaultZoneRadius;

  // Selected residence ID for highlighting
  int? _selectedResidenceId;

  @override
  void initState() {
    super.initState();
    _loadResidencesFromBloc();
    _getCurrentLocation();
  }

  /// Charge les appartements depuis le AppartementBloc et les convertit en pins.
  void _loadResidencesFromBloc() {
    final bloc = context.read<AppartementBloc>();
    final state = bloc.state;
    final apparts = state.appartements;
    if (apparts.isNotEmpty) {
      _updateMapResidences(apparts);
    } else {
      bloc.add(LoadAppartements());
    }
  }

  /// Filtre les appartements géolocalisés et les convertit en MapResidence
  /// (un pin par appartement — modèle plat post-refonte).
  void _updateMapResidences(List<Appartement> appartements) {
    setState(() {
      _mapResidences = appartements
          .where((a) => a.address?.hasExactLocation == true)
          .map((a) => MapResidence.fromAppartement(a))
          .toList();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _locationButtonState = LocationButtonState.searching);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationButtonState = LocationButtonState.inactive;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _locationButtonState = LocationButtonState.inactive;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationButtonState = LocationButtonState.inactive;
        });
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {
        _isLoadingLocation = false;
        _locationButtonState = LocationButtonState.centered;
      });
    } catch (e) {
      debugPrint('Erreur géolocalisation: $e');
      setState(() {
        _isLoadingLocation = false;
        _locationButtonState = LocationButtonState.inactive;
      });
    }
  }

  void _onMapMoved(MapCamera position, bool hasGesture) {
    if (hasGesture && mounted) {
      setState(() => _locationButtonState = LocationButtonState.inactive);
    }
  }

  /// Long press sur la carte pour sélectionner une position manuellement
  void _onMapLongPress(TapPosition tapPosition, LatLng point) {
    _mapController.move(point, MapConfig.selectedZoom);
    setState(() {
      _zoneCenter = point;
      _locationButtonState = LocationButtonState.inactive;
    });
  }

  void _centerOnUserLocation() async {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        MapConfig.userPositionZoom,
      );
      setState(() => _locationButtonState = LocationButtonState.centered);
    } else {
      await _getCurrentLocation();
    }
  }

  void _onResidenceMarkerTapped(MapResidence residence) {
    setState(() => _selectedResidenceId = residence.id);
    _showResidenceDetails(residence);
  }

  void _showResidenceDetails(MapResidence residence) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: MapConfig.detailsSheetInitialSize,
        minChildSize: MapConfig.detailsSheetMinSize,
        maxChildSize: MapConfig.detailsSheetMaxSize,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  TextSeed(
                    residence.nom ?? 'Résidence',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  TextSeed(
                    residence.addressDescription ?? 'Adresse non disponible',
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: MapInfoCard(
                          title: 'Appartements',
                          value: residence.apartmentCountText,
                          icon: Icons.home_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MapInfoCard(
                          title: 'Prix',
                          value: residence.formattedPriceRange,
                          icon: Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  if (residence.communeName != null) ...[
                    const SizedBox(height: 12),
                    MapInfoCard(
                      title: 'Commune',
                      value: residence.communeName!,
                      icon: Icons.location_city_outlined,
                    ),
                  ],
                  const SizedBox(height: 24),
                  PlainButton(
                    value: 'Voir les appartements',
                    onPress: () {
                      Navigator.of(context).pop();
                      pushScreen(
                        context,
                        OwnerAppartementsScreen(
                          residence.proprietaire?.id ?? 0,
                          residence.proprietaire?.nom ?? 'Propriétaire',
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      setState(() => _selectedResidenceId = null);
    });
  }

  void _showZoneSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ZoneSelector(
        initialRadius: _zoneRadius,
        onSearch: () {
          Navigator.pop(context);
          _activateZoneMode();
        },
        onClear: () {
          Navigator.pop(context);
          _clearZone();
        },
        onRadiusChanged: (radius) {
          setState(() => _zoneRadius = radius);
        },
      ),
    );
  }

  void _activateZoneMode() {
    final center = _mapController.camera.center;
    setState(() {
      _isZoneModeActive = true;
      _zoneCenter = center;
    });
  }

  void _clearZone() {
    setState(() {
      _isZoneModeActive = false;
      _zoneCenter = null;
    });
  }

  List<Marker> _getResidenceMarkers() {
    return ResidenceMarkersBuilder(
      residences: _mapResidences,
      selectedResidenceId: _selectedResidenceId,
      onResidenceTapped: _onResidenceMarkerTapped,
    ).build();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextSeed('Carte', fontSize: 18, fontWeight: FontWeight.w600),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: AppColors.textPrimary),
            onPressed: () {
              context.read<AppartementBloc>().add(RefreshAppartements());
            },
          ),
        ],
      ),
      body: BlocConsumer<AppartementBloc, AppartementState>(
        listener: (context, state) {
          if (state is AppartementLoaded || state is ProprietaireAppartementsLoaded) {
            _updateMapResidences(state.appartements);
          } else if (state is AppartementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_isLoadingLocation && state is AppartementLoading) {
            return const Center(child: CircularProgress());
          }

          if (state is AppartementLoading && _mapResidences.isEmpty) {
            return const Center(child: CircularProgress());
          }

          if (state is AppartementError && _mapResidences.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  TextSeed(
                    state.message,
                    textAlign: TextAlign.center,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 24),
                  PlainButton(
                    value: 'Réessayer',
                    onPress: () {
                      context.read<AppartementBloc>().add(LoadAppartements());
                    },
                  ),
                ],
              ),
            );
          }

          // Aucun appartement géolocalisé
          if (_mapResidences.isEmpty && (state is AppartementLoaded || state is ProprietaireAppartementsLoaded)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  TextSeed(
                    'Aucune résidence avec localisation',
                    textAlign: TextAlign.center,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  TextSeed(
                    '${state.appartements.length} appartement(s) sans coordonnées GPS',
                    textAlign: TextAlign.center,
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            );
          }

          final center = _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : const LatLng(5.3478, -4.0267); // Abidjan par défaut

          return Stack(
            children: [
              // Carte
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: MapConfig.defaultZoom,
                  onPositionChanged: _onMapMoved,
                  onLongPress: _onMapLongPress,
                ),
                children: [
                  // Tuiles stylisées (dark mode)
                  const MapStyleLayer(isDarkMode: true),

                  // Zone sélectionnée
                  if (_isZoneModeActive && _zoneCenter != null)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _zoneCenter!,
                          radius: _zoneRadius * 1000, // km to meters
                          useRadiusInMeter: true,
                          color: MapConfig.zoneColor,
                          borderColor: MapConfig.zoneBorderColor,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),

                  // Marqueurs
                  MarkerLayer(
                    markers: [
                      // Position actuelle
                      if (_currentPosition != null)
                        Marker(
                          point: LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          ),
                          width: 24,
                          height: 24,
                          child: const CurrentPositionMarker(),
                        ),

                      // Résidences
                      ..._getResidenceMarkers(),
                    ],
                  ),
                ],
              ),

              // Compteur de résidences
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextSeed(
                    '${_mapResidences.length} résidence(s)',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // FABs
              Positioned(
                right: MapConfig.fabMargin,
                bottom: MapConfig.fabMargin + 60,
                child: LocationButton(
                  state: _locationButtonState,
                  onPressed: _centerOnUserLocation,
                ),
              ),

              Positioned(
                right: MapConfig.fabMargin,
                bottom: MapConfig.fabMargin,
                child: Material(
                  elevation: 4,
                  shape: const CircleBorder(),
                  color: _isZoneModeActive ? AppColors.accent : AppColors.white,
                  child: InkWell(
                    onTap: _showZoneSelector,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: MapConfig.fabSize,
                      height: MapConfig.fabSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: MapConfig.fabShadow,
                      ),
                      child: Icon(
                        Icons.crop_free,
                        color: _isZoneModeActive ? AppColors.white : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
