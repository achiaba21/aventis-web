import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/geocoding/geocoding_result.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/location_util.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/loader/circular_progress.dart';
import 'package:asfar/widget/map/map_search_bar.dart';
import 'package:asfar/widget/map/map_style_layer.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran de sélection de position sur une carte
class LocationPickerMapScreen extends StatefulWidget {
  const LocationPickerMapScreen({
    super.key,
    this.initialPosition,
  });

  /// Position initiale (optionnelle)
  final LatLng? initialPosition;

  @override
  State<LocationPickerMapScreen> createState() =>
      _LocationPickerMapScreenState();
}

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedPosition;
  LatLng? _currentPosition;
  bool _isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _initializePosition();
  }

  Future<void> _initializePosition() async {
    // Si position initiale fournie, l'utiliser
    if (widget.initialPosition != null) {
      setState(() {
        _selectedPosition = widget.initialPosition;
        _isLoadingLocation = false;
      });
      return;
    }

    // Sinon, récupérer la position actuelle
    final position = await LocationUtil.getCurrentLatLng();
    if (position != null) {
      setState(() {
        _currentPosition = position;
        _selectedPosition = position;
        _isLoadingLocation = false;
      });
    } else {
      // Position par défaut (Abidjan, Côte d'Ivoire)
      setState(() {
        _selectedPosition = const LatLng(5.3478, -4.0267);
        _isLoadingLocation = false;
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) {
    setState(() => _selectedPosition = position);
  }

  void _onSearchResult(GeocodingResult result) {
    setState(() => _selectedPosition = result.latLng);
    _mapController.move(result.latLng, 15.0);
  }

  void _onConfirm() {
    if (_selectedPosition != null) {
      Navigator.of(context).pop(_selectedPosition);
    }
  }

  void _centerOnCurrentLocation() async {
    final position = await LocationUtil.getCurrentLatLng();
    if (position != null && mounted) {
      _mapController.move(position, 15.0);
      setState(() {
        _selectedPosition = position;
        _currentPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextSeed(
          "Select location on map",
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.my_location, color: AppColors.accent),
            onPressed: _centerOnCurrentLocation,
            tooltip: "My location",
          ),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgress())
          : Column(
              children: [
                // Barre de recherche
                Container(
                  padding: EdgeInsets.all(Espacement.paddingBloc),
                  color: AppColors.background,
                  child: MapSearchBar(onLocationSelected: _onSearchResult),
                ),

                // Instructions
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Espacement.paddingBloc,
                    vertical: 8,
                  ),
                  color: AppColors.background,
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.accent,
                        size: 20,
                      ),
                      SizedBox(width: Espacement.gapSection / 2),
                      Expanded(
                        child: TextSeed(
                          "Tap on the map to select a location",
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Carte
                Expanded(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _selectedPosition ??
                          const LatLng(5.3478, -4.0267),
                      initialZoom: 15.0,
                      onTap: _onMapTap,
                    ),
                    children: [
                      const MapStyleLayer(),
                      MarkerLayer(
                        markers: [
                          // Marqueur de la position actuelle
                          if (_currentPosition != null)
                            Marker(
                              point: _currentPosition!,
                              width: 30,
                              height: 30,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.info,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: AppColors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          // Marqueur de la position sélectionnée
                          if (_selectedPosition != null)
                            Marker(
                              point: _selectedPosition!,
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_pin,
                                color: AppColors.accent,
                                size: 40,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Coordonnées sélectionnées
                if (_selectedPosition != null)
                  Container(
                    padding: EdgeInsets.all(Espacement.paddingBloc / 2),
                    color: AppColors.background,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.place,
                          color: AppColors.accent,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        TextSeed(
                          "Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, "
                          "Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}",
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),

                // Bouton de confirmation
                Container(
                  padding: EdgeInsets.all(Espacement.paddingBloc),
                  color: AppColors.background,
                  child: CustomButton(
                    text: "Confirm location",
                    onPressed: _selectedPosition != null ? _onConfirm : null,
                  ),
                ),
              ],
            ),
    );
  }
}
