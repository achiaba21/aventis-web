import 'package:latlong2/latlong.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/map/map_appartement.dart';

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

  const MapAppartementsLoaded({
    required this.appartements,
    required this.center,
    required this.radiusKm,
    this.filter,
  });

  MapAppartementsLoaded copyWith({
    List<MapAppartement>? appartements,
    LatLng? center,
    double? radiusKm,
    FilterCriteria? filter,
  }) {
    return MapAppartementsLoaded(
      appartements: appartements ?? this.appartements,
      center: center ?? this.center,
      radiusKm: radiusKm ?? this.radiusKm,
      filter: filter ?? this.filter,
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

  const MapEmpty({
    required this.message,
    required this.center,
    required this.radiusKm,
    this.filter,
  });
}
