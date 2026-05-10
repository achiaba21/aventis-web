import 'package:asfar/model/locolite/lieux/commune.dart';

/// Modèle data : données de localisation collectées dans un formulaire.
///
/// Précédemment défini dans `widget/form/location_picker.dart` (couplage UI ↔
/// données). Extrait dans le layer model pour que les BLoCs/services puissent
/// le manipuler sans dépendre du widget.
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
