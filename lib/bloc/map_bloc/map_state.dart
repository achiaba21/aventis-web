import 'package:latlong2/latlong.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/map/map_search_result.dart';

abstract class MapState {
  const MapState();
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapAppartementsLoaded extends MapState {
  final List<MapAppartement> appartements;
  final LatLng center;
  final double radiusKm;
  final FilterCriteria? filter;

  /// Nom de zone reverse-geocodé côté backend (R-BACK2). Null si non fourni
  /// — l'UI affiche alors un fallback "dans cette zone".
  final String? zoneName;

  const MapAppartementsLoaded({
    required this.appartements,
    required this.center,
    required this.radiusKm,
    this.filter,
    this.zoneName,
  });

  MapAppartementsLoaded copyWith({
    List<MapAppartement>? appartements,
    LatLng? center,
    double? radiusKm,
    FilterCriteria? filter,
    String? zoneName,
  }) {
    return MapAppartementsLoaded(
      appartements: appartements ?? this.appartements,
      center: center ?? this.center,
      radiusKm: radiusKm ?? this.radiusKm,
      filter: filter ?? this.filter,
      zoneName: zoneName ?? this.zoneName,
    );
  }
}

class MapAppartementSelected extends MapState {
  final MapAppartement selectedAppartement;
  final List<MapAppartement>? allAppartements;
  final LatLng center;
  final double radiusKm;
  final FilterCriteria? filter;

  const MapAppartementSelected({
    required this.selectedAppartement,
    this.allAppartements,
    required this.center,
    required this.radiusKm,
    this.filter,
  });
}

class MapAppartementDetailsLoaded extends MapState {
  final MapAppartement appartementDetails;
  final LatLng? realLocation;

  const MapAppartementDetailsLoaded({
    required this.appartementDetails,
    this.realLocation,
  });
}

class MapError extends MapState {
  final String message;
  final String? errorType;
  final bool canRetry;

  const MapError({
    required this.message,
    this.errorType,
    this.canRetry = true,
  });
}

class MapNetworkError extends MapError {
  const MapNetworkError({
    required super.message,
  }) : super(
          errorType: 'network',
          canRetry: true,
        );
}

class MapLocationError extends MapError {
  const MapLocationError({
    required super.message,
  }) : super(
          errorType: 'location',
          canRetry: true,
        );
}

class MapFilterUpdated extends MapState {
  final FilterCriteria? filter;
  final LatLng center;
  final double radiusKm;

  const MapFilterUpdated({
    this.filter,
    required this.center,
    required this.radiusKm,
  });
}

class MapCenterUpdated extends MapState {
  final LatLng center;
  final FilterCriteria? filter;

  const MapCenterUpdated({
    required this.center,
    this.filter,
  });
}

class MapRealLocationLoaded extends MapState {
  final int appartementId;
  final LatLng realLocation;

  const MapRealLocationLoaded({
    required this.appartementId,
    required this.realLocation,
  });
}

class MapEmpty extends MapState {
  final String message;
  final LatLng center;
  final double radiusKm;
  final FilterCriteria? filter;

  /// Nom de zone reverse-geocodé côté backend (R-BACK2). Null si non fourni.
  final String? zoneName;

  const MapEmpty({
    required this.message,
    required this.center,
    required this.radiusKm,
    this.filter,
    this.zoneName,
  });
}

/// Recherche textuelle de lieu en cours (geocoding).
class MapPlaceSearchLoading extends MapState {
  const MapPlaceSearchLoading();
}

/// Recherche réussie — l'UI doit recentrer la carte sur `result.position`.
class MapPlaceSearchSuccess extends MapState {
  final MapSearchResult result;

  const MapPlaceSearchSuccess({required this.result});
}

/// Recherche échouée (404 lieu inconnu ou erreur réseau).
class MapPlaceSearchError extends MapState {
  final String message;

  const MapPlaceSearchError({required this.message});
}
