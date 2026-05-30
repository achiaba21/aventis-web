import 'package:latlong2/latlong.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/model/map/map_search_result.dart';

/// States du BLoC carte démarcheur — V9.7d.
abstract class DemarcheurMapState {
  const DemarcheurMapState();
}

class DemarcheurMapInitial extends DemarcheurMapState {
  const DemarcheurMapInitial();
}

class DemarcheurMapLoading extends DemarcheurMapState {
  const DemarcheurMapLoading();
}

class DemarcheurMapAppartementsLoaded extends DemarcheurMapState {
  final List<MapAppartement> appartements;
  final LatLng center;
  final double radiusKm;

  /// Nom de zone reverse-geocodé côté backend (R-BACK2). Null si non fourni.
  final String? zoneName;

  const DemarcheurMapAppartementsLoaded({
    required this.appartements,
    required this.center,
    required this.radiusKm,
    this.zoneName,
  });
}

class DemarcheurMapEmpty extends DemarcheurMapState {
  final String message;
  final LatLng center;
  final double radiusKm;
  final String? zoneName;

  const DemarcheurMapEmpty({
    required this.message,
    required this.center,
    required this.radiusKm,
    this.zoneName,
  });
}

class DemarcheurMapError extends DemarcheurMapState {
  final String message;
  final bool canRetry;

  const DemarcheurMapError({
    required this.message,
    this.canRetry = true,
  });
}

class DemarcheurMapCenterUpdated extends DemarcheurMapState {
  final LatLng center;

  const DemarcheurMapCenterUpdated({required this.center});
}

class DemarcheurMapPlaceSearchLoading extends DemarcheurMapState {
  const DemarcheurMapPlaceSearchLoading();
}

class DemarcheurMapPlaceSearchSuccess extends DemarcheurMapState {
  final MapSearchResult result;

  const DemarcheurMapPlaceSearchSuccess({required this.result});
}

class DemarcheurMapPlaceSearchError extends DemarcheurMapState {
  final String message;

  const DemarcheurMapPlaceSearchError({required this.message});
}
