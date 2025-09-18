import 'package:latlong2/latlong.dart';
import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/map/map_residence.dart';

abstract class MapState {
  const MapState();
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapLoading extends MapState {
  const MapLoading();
}

class MapResidencesLoaded extends MapState {
  final List<MapResidence> residences;
  final LatLng center;
  final double radiusKm;
  final FilterCriteria? filter;
  final bool isClusterMode;

  const MapResidencesLoaded({
    required this.residences,
    required this.center,
    required this.radiusKm,
    this.filter,
    this.isClusterMode = false,
  });

  MapResidencesLoaded copyWith({
    List<MapResidence>? residences,
    LatLng? center,
    double? radiusKm,
    FilterCriteria? filter,
    bool? isClusterMode,
  }) {
    return MapResidencesLoaded(
      residences: residences ?? this.residences,
      center: center ?? this.center,
      radiusKm: radiusKm ?? this.radiusKm,
      filter: filter ?? this.filter,
      isClusterMode: isClusterMode ?? this.isClusterMode,
    );
  }
}

class MapClustersLoaded extends MapState {
  final List<MapCluster> clusters;
  final LatLng center;
  final double radiusKm;
  final double clusterRadiusKm;
  final FilterCriteria? filter;

  const MapClustersLoaded({
    required this.clusters,
    required this.center,
    required this.radiusKm,
    required this.clusterRadiusKm,
    this.filter,
  });

  MapClustersLoaded copyWith({
    List<MapCluster>? clusters,
    LatLng? center,
    double? radiusKm,
    double? clusterRadiusKm,
    FilterCriteria? filter,
  }) {
    return MapClustersLoaded(
      clusters: clusters ?? this.clusters,
      center: center ?? this.center,
      radiusKm: radiusKm ?? this.radiusKm,
      clusterRadiusKm: clusterRadiusKm ?? this.clusterRadiusKm,
      filter: filter ?? this.filter,
    );
  }
}

class MapResidenceSelected extends MapState {
  final MapResidence selectedResidence;
  final List<MapResidence>? allResidences;
  final List<MapCluster>? clusters;
  final LatLng center;
  final double radiusKm;
  final FilterCriteria? filter;
  final bool isClusterMode;

  const MapResidenceSelected({
    required this.selectedResidence,
    this.allResidences,
    this.clusters,
    required this.center,
    required this.radiusKm,
    this.filter,
    this.isClusterMode = false,
  });
}

class MapResidenceDetailsLoaded extends MapState {
  final MapResidence residenceDetails;
  final LatLng? realLocation;

  const MapResidenceDetailsLoaded({
    required this.residenceDetails,
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
    required String message,
  }) : super(
          message: message,
          errorType: 'network',
          canRetry: true,
        );
}

class MapLocationError extends MapError {
  const MapLocationError({
    required String message,
  }) : super(
          message: message,
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
  final int residenceId;
  final LatLng realLocation;

  const MapRealLocationLoaded({
    required this.residenceId,
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