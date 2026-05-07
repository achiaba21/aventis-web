import 'dart:async';

import 'package:asfar/util/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/geocoding/geocoding_result.dart';
import 'package:asfar/model/locolite/lieux/commune.dart';
import 'package:asfar/screen/map/location_picker_map_screen.dart';
import 'package:asfar/service/geocoding/geocoding_service.dart';
import 'package:asfar/util/location_util.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/map/map_style_layer.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class LocationData {
  String? selectedLocation;
  String? gpsAddress;
  String? streetAddress;
  bool useCurrentLocation;
  double? latitude;
  double? longitude;
  Commune? commune;

  LocationData({
    this.selectedLocation,
    this.gpsAddress,
    this.streetAddress,
    this.useCurrentLocation = false,
    this.latitude,
    this.longitude,
    this.commune,
  });

  LocationData copyWith({
    String? selectedLocation,
    String? gpsAddress,
    String? streetAddress,
    bool? useCurrentLocation,
    double? latitude,
    double? longitude,
    Commune? commune,
  }) {
    return LocationData(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      gpsAddress: gpsAddress ?? this.gpsAddress,
      streetAddress: streetAddress ?? this.streetAddress,
      useCurrentLocation: useCurrentLocation ?? this.useCurrentLocation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      commune: commune ?? this.commune,
    );
  }
}

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    required this.locationData,
    required this.onLocationChanged,
  });

  final LocationData locationData;
  final Function(LocationData) onLocationChanged;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  bool _isLoadingLocation = false;

  // Recherche de lieu
  final TextEditingController _searchController = TextEditingController();
  List<GeocodingResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;
  bool _showSuggestions = false;
  GeocodingResult? _selectedResult;

  // TODO: Communes - endpoint à fournir
  List<Commune> _communes = [];
  bool _isLoadingCommunes = false;

  final TextEditingController _streetAddressController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-remplir le champ de recherche si une localisation existe
    if (widget.locationData.selectedLocation != null) {
      _searchController.text = widget.locationData.selectedLocation!;
    }
    // TODO: Charger les communes depuis le serveur
    _loadCommunes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// TODO: Charger les communes depuis le serveur
  Future<void> _loadCommunes() async {
    // TODO: Implémenter quand l'endpoint sera fourni
    // setState(() => _isLoadingCommunes = true);
    // final communes = await CommuneService.instance.getAllCommunes();
    // setState(() {
    //   _communes = communes;
    //   _isLoadingCommunes = false;
    // });
  }

  /// Recherche de lieu avec debounce
  void _onSearchChanged(String query) {
    _debounce?.cancel();

    if (query.trim().length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await GeocodingService.instance.autocomplete(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
          _showSuggestions = results.isNotEmpty;
        });
      }
    });
  }

  /// Sélection d'un lieu depuis les suggestions
  void _onLocationSelected(GeocodingResult result) {
    final locationData = widget.locationData;
    setState(() {
      _searchController.text = result.displayName;

      _selectedResult = result;
      _streetAddressController.text = result.address?.street ?? '';
      _showSuggestions = false;
      _searchResults = [];
    });

    // Auto-remplir les champs
    widget.onLocationChanged(
      locationData.copyWith(
        selectedLocation: result.displayName,
        latitude: result.lat,
        longitude: result.lon,
        streetAddress: result.displayName,
      ),
    );

    // TODO: Essayer de matcher la commune dans le dropdown
    _tryMatchCommune(result.displayName);
  }

  /// TODO: Matcher la commune depuis le nom du lieu
  void _tryMatchCommune(String locationName) {
    // TODO: Implémenter quand les communes seront chargées
    // Chercher si le nom contient une commune connue
    // for (final commune in _communes) {
    //   if (locationName.toLowerCase().contains(commune.nom?.toLowerCase() ?? '')) {
    //     widget.onLocationChanged(
    //       widget.locationData.copyWith(commune: commune),
    //     );
    //     break;
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationSearchField(),
        SizedBox(height: Espacement.gapSection),
        _buildCommuneDropdown(),
        SizedBox(height: Espacement.gapSection),
        _buildCurrentLocationButton(),
        SizedBox(height: Espacement.gapSection),
        _buildGpsAddressField(),
        SizedBox(height: Espacement.gapSection),
        _buildStreetAddressField(),
        SizedBox(height: Espacement.gapSection),
        _buildMapPlaceholder(),
      ],
    );
  }

  /// Champ de recherche avec autocomplete
  Widget _buildLocationSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(
          "Rechercher un lieu",
          fontSize: 14,
          color: AppColors.background,
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary),
            borderRadius: BorderRadius.circular(Espacement.radius),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onTap: () {
              if (_searchResults.isNotEmpty) {
                setState(() => _showSuggestions = true);
              }
            },
            style: TextStyle(color: AppColors.background),
            decoration: InputDecoration(
              hintText: "Ex: Cocody, Abidjan",
              hintStyle: TextStyle(color: AppColors.textMuted),
              prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
              suffixIcon:
                  _isSearching
                      ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                      )
                      : _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchResults = [];
                            _showSuggestions = false;
                          });
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Espacement.paddingInput,
                vertical: 14,
              ),
            ),
          ),
        ),
        // Suggestions
        if (_showSuggestions && _searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(Espacement.radius),
              border: Border.all(color: AppColors.textSecondary),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _searchResults.length,
              separatorBuilder:
                  (_, __) => Divider(height: 1, color: AppColors.textSecondary),
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  title: TextSeed(
                    result.displayName,
                    fontSize: 13,
                    color: AppColors.white,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  dense: true,
                  onTap: () => _onLocationSelected(result),
                );
              },
            ),
          ),
      ],
    );
  }

  /// Dropdown pour sélectionner la commune
  /// TODO: Charger les communes depuis le serveur
  Widget _buildCommuneDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed("Commune", fontSize: 14, color: AppColors.background),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Espacement.paddingInput,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary),
            borderRadius: BorderRadius.circular(Espacement.radius),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Commune>(
              value: widget.locationData.commune,
              hint: TextSeed(
                "Sélectionner une commune",
                color: AppColors.textMuted,
                fontSize: 14,
              ),
              isExpanded: true,
              dropdownColor: AppColors.background,
              icon:
                  _isLoadingCommunes
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accent,
                        ),
                      )
                      : Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textMuted,
                      ),
              items:
                  _communes.map((commune) {
                    return DropdownMenuItem<Commune>(
                      value: commune,
                      child: TextSeed(
                        commune.nom ?? '',
                        color: AppColors.background,
                        fontSize: 14,
                      ),
                    );
                  }).toList(),
              onChanged: (commune) {
                widget.onLocationChanged(
                  widget.locationData.copyWith(commune: commune),
                );
              },
            ),
          ),
        ),
        // TODO: Message temporaire
        if (_communes.isEmpty && !_isLoadingCommunes)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: TextSeed(
              "TODO: Endpoint communes à configurer",
              fontSize: 11,
              color: AppColors.warning,
            ),
          ),
      ],
    );
  }

  Widget _buildCurrentLocationButton() {
    return TextButton.icon(
      onPressed: _isLoadingLocation ? null : _handleGetCurrentLocation,
      icon:
          _isLoadingLocation
              ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              )
              : Icon(Icons.my_location, color: AppColors.accent, size: 20),
      label: TextSeed(
        _isLoadingLocation ? "Getting location..." : "Use my current location",
        fontSize: 16,
        color: AppColors.accent,
      ),
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Future<void> _handleGetCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    final position = await LocationUtil.getCurrentLatLng();

    if (position != null && mounted) {
      widget.onLocationChanged(
        widget.locationData.copyWith(
          useCurrentLocation: true,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Location retrieved: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (mounted) {
      final errorMessage = await LocationUtil.getPermissionErrorMessage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage ?? "Unable to get location"),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Widget _buildGpsAddressField() {
    return InputField(
      libelle: "GPS address of property",
      placeHolder: "GE-000000",
      initialValue: widget.locationData.gpsAddress,
      onChange: (value) {
        widget.onLocationChanged(
          widget.locationData.copyWith(gpsAddress: value),
        );
        return null;
      },
    );
  }

  Widget _buildStreetAddressField() {
    return InputField(
      libelle: "Street address/Landmark (Optional)",
      placeHolder: "Enter street address",
      controller: _streetAddressController,
      onChange: (value) {
        widget.onLocationChanged(
          widget.locationData.copyWith(streetAddress: value),
        );
        return null;
      },
    );
  }

  Widget _buildMapPlaceholder() {
    final hasLocation =
        widget.locationData.latitude != null &&
        widget.locationData.longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed(
          "Sélectionner un emplacement précis sur la carte.",
          fontSize: 14,
          color: AppColors.accent,
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _handleOpenMapPicker,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(Espacement.radius),
              border: Border.all(
                color: hasLocation ? AppColors.accent : AppColors.border,
                width: hasLocation ? 2 : 1,
              ),
            ),
            child:
                hasLocation
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(Espacement.radius),
                      child: Stack(
                        children: [
                          // Mini carte avec la position sélectionnée
                          FlutterMap(
                            key: ValueKey(
                              '${widget.locationData.latitude}_${widget.locationData.longitude}',
                            ),
                            options: MapOptions(
                              initialCenter: LatLng(
                                widget.locationData.latitude!,
                                widget.locationData.longitude!,
                              ),
                              initialZoom: 15.0,
                              interactionOptions: const InteractionOptions(
                                flags:
                                    InteractiveFlag
                                        .none, // Désactiver les interactions
                              ),
                            ),
                            children: [
                              const MapStyleLayer(),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      widget.locationData.latitude!,
                                      widget.locationData.longitude!,
                                    ),
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
                          // Overlay transparent pour capturer tous les clics
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleOpenMapPicker,
                                child: Container(color: Colors.transparent),
                              ),
                            ),
                          ),
                          // Overlay pour indiquer que c'est cliquable
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.textPrimary.withValues(alpha: 0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextSeed(
                                        "Lat: ${widget.locationData.latitude!.toStringAsFixed(4)}, "
                                        "Lng: ${widget.locationData.longitude!.toStringAsFixed(4)}",
                                        fontSize: 11,
                                        color: AppColors.white,
                                      ),
                                    ),
                                    Icon(
                                      Icons.edit_location,
                                      color: AppColors.accent,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          TextSeed(
                            "Aucun emplacement sélectionné",
                            color: AppColors.textSecondary,
                          ),
                          TextSeed(
                            "Appuyez pour sélectionner",
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleOpenMapPicker() async {
    // Préparer la position initiale
    LatLng? initialPosition;
    if (widget.locationData.latitude != null &&
        widget.locationData.longitude != null) {
      initialPosition = LatLng(
        widget.locationData.latitude!,
        widget.locationData.longitude!,
      );
    }

    // Ouvrir l'écran de sélection
    final selectedPosition = await pushScreen<LatLng>(
      context,
      LocationPickerMapScreen(initialPosition: initialPosition),
    );

    // Mettre à jour les données si une position a été sélectionnée
    if (selectedPosition != null && mounted) {
      widget.onLocationChanged(
        widget.locationData.copyWith(
          latitude: selectedPosition.latitude,
          longitude: selectedPosition.longitude,
          useCurrentLocation: false,
        ),
      );
    }
  }
}
