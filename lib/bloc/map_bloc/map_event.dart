import 'package:latlong2/latlong.dart';
import 'package:web_flutter/model/filter/filter_criteria.dart';

abstract class MapEvent {
  const MapEvent();
}

class LoadMapResidences extends MapEvent {
  final LatLng center;
  final double radiusKm;

  const LoadMapResidences({
    required this.center,
    this.radiusKm = 10.0,
  });
}

class LoadFilteredMapResidences extends MapEvent {
  final LatLng center;
  final double radiusKm;
  final FilterCriteria? filter;

  const LoadFilteredMapResidences({
    required this.center,
    this.radiusKm = 10.0,
    this.filter,
  });
}

class LoadClusteredMapResidences extends MapEvent {
  final LatLng center;
  final double radiusKm;
  final double clusterRadiusKm;
  final FilterCriteria? filter;

  const LoadClusteredMapResidences({
    required this.center,
    this.radiusKm = 10.0,
    this.clusterRadiusKm = 0.5,
    this.filter,
  });
}

class SelectMapResidence extends MapEvent {
  final int residenceId;

  const SelectMapResidence(this.residenceId);
}

class LoadResidenceDetails extends MapEvent {
  final int residenceId;

  const LoadResidenceDetails(this.residenceId);
}

class UpdateMapCenter extends MapEvent {
  final LatLng center;

  const UpdateMapCenter(this.center);
}

class UpdateMapFilter extends MapEvent {
  final FilterCriteria? filter;

  const UpdateMapFilter(this.filter);
}

class RefreshMapData extends MapEvent {
  const RefreshMapData();
}

class ClearMapSelection extends MapEvent {
  const ClearMapSelection();
}

class RequestRealLocation extends MapEvent {
  final int residenceId;

  const RequestRealLocation(this.residenceId);
}

class ToggleClusterMode extends MapEvent {
  final bool enableClustering;

  const ToggleClusterMode(this.enableClustering);
}