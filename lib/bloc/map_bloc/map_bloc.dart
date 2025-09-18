import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:web_flutter/bloc/map_bloc/map_event.dart';
import 'package:web_flutter/bloc/map_bloc/map_state.dart';
import 'package:web_flutter/model/filter/filter_criteria.dart';
import 'package:web_flutter/model/map/map_residence.dart';
import 'package:web_flutter/service/model/map/map_service.dart';
import 'package:web_flutter/util/function.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final MapService _mapService = MapService();

  // Variables d'état internes
  LatLng? _currentCenter;
  double _currentRadius = 10.0;
  FilterCriteria? _currentFilter;
  bool _isClusterMode = false;
  List<MapResidence>? _cachedResidences;
  List<MapCluster>? _cachedClusters;

  MapBloc() : super(const MapInitial()) {
    on<LoadMapResidences>(_onLoadMapResidences);
    on<LoadFilteredMapResidences>(_onLoadFilteredMapResidences);
    on<LoadClusteredMapResidences>(_onLoadClusteredMapResidences);
    on<SelectMapResidence>(_onSelectMapResidence);
    on<LoadResidenceDetails>(_onLoadResidenceDetails);
    on<UpdateMapCenter>(_onUpdateMapCenter);
    on<UpdateMapFilter>(_onUpdateMapFilter);
    on<RefreshMapData>(_onRefreshMapData);
    on<ClearMapSelection>(_onClearMapSelection);
    on<RequestRealLocation>(_onRequestRealLocation);
    on<ToggleClusterMode>(_onToggleClusterMode);
  }

  Future<void> _onLoadMapResidences(
    LoadMapResidences event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      _currentCenter = event.center;
      _currentRadius = event.radiusKm;
      _isClusterMode = false;

      final residences = await _mapService.getMapResidences(
        center: event.center,
        radiusKm: event.radiusKm,
      );

      _cachedResidences = residences;
      _cachedClusters = null;

      if (residences.isEmpty) {
        emit(MapEmpty(
          message: "Aucune résidence trouvée dans cette zone",
          center: event.center,
          radiusKm: event.radiusKm,
        ));
      } else {
        emit(MapResidencesLoaded(
          residences: residences,
          center: event.center,
          radiusKm: event.radiusKm,
          isClusterMode: false,
        ));
      }
    } catch (e) {
      deboger('Erreur MapBloc.LoadMapResidences: $e');
      emit(MapNetworkError(message: 'Erreur lors du chargement des résidences: $e'));
    }
  }

  Future<void> _onLoadFilteredMapResidences(
    LoadFilteredMapResidences event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      _currentCenter = event.center;
      _currentRadius = event.radiusKm;
      _currentFilter = event.filter;
      _isClusterMode = false;

      final residences = await _mapService.getFilteredMapResidences(
        center: event.center,
        radiusKm: event.radiusKm,
        filter: event.filter,
      );

      _cachedResidences = residences;
      _cachedClusters = null;

      if (residences.isEmpty) {
        emit(MapEmpty(
          message: "Aucune résidence ne correspond à vos critères",
          center: event.center,
          radiusKm: event.radiusKm,
          filter: event.filter,
        ));
      } else {
        emit(MapResidencesLoaded(
          residences: residences,
          center: event.center,
          radiusKm: event.radiusKm,
          filter: event.filter,
          isClusterMode: false,
        ));
      }
    } catch (e) {
      deboger('Erreur MapBloc.LoadFilteredMapResidences: $e');
      emit(MapNetworkError(message: 'Erreur lors du chargement des résidences filtrées: $e'));
    }
  }

  Future<void> _onLoadClusteredMapResidences(
    LoadClusteredMapResidences event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      _currentCenter = event.center;
      _currentRadius = event.radiusKm;
      _currentFilter = event.filter;
      _isClusterMode = true;

      final clusters = await _mapService.getClusteredResidences(
        center: event.center,
        radiusKm: event.radiusKm,
        clusterRadiusKm: event.clusterRadiusKm,
        filter: event.filter,
      );

      _cachedClusters = clusters;
      _cachedResidences = null;

      if (clusters.isEmpty) {
        emit(MapEmpty(
          message: "Aucune résidence trouvée dans cette zone",
          center: event.center,
          radiusKm: event.radiusKm,
          filter: event.filter,
        ));
      } else {
        emit(MapClustersLoaded(
          clusters: clusters,
          center: event.center,
          radiusKm: event.radiusKm,
          clusterRadiusKm: event.clusterRadiusKm,
          filter: event.filter,
        ));
      }
    } catch (e) {
      deboger('Erreur MapBloc.LoadClusteredMapResidences: $e');
      emit(MapNetworkError(message: 'Erreur lors du chargement des clusters: $e'));
    }
  }

  Future<void> _onSelectMapResidence(
    SelectMapResidence event,
    Emitter<MapState> emit,
  ) async {
    try {
      MapResidence? selectedResidence;

      // Chercher dans les résidences cachées ou les clusters
      if (_cachedResidences != null) {
        selectedResidence = _cachedResidences!.firstWhere(
          (r) => r.id == event.residenceId,
          orElse: () => throw Exception('Résidence non trouvée'),
        );
      } else if (_cachedClusters != null) {
        for (final cluster in _cachedClusters!) {
          try {
            selectedResidence = cluster.residences.firstWhere(
              (r) => r.id == event.residenceId,
            );
            break;
          } catch (e) {
            continue;
          }
        }
      }

      if (selectedResidence != null) {
        emit(MapResidenceSelected(
          selectedResidence: selectedResidence,
          allResidences: _cachedResidences,
          clusters: _cachedClusters,
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: _currentFilter,
          isClusterMode: _isClusterMode,
        ));
      } else {
        // Si pas trouvé dans le cache, faire un appel API
        final residenceDetails = await _mapService.getResidenceDetails(event.residenceId);
        if (residenceDetails != null) {
          emit(MapResidenceSelected(
            selectedResidence: residenceDetails,
            allResidences: _cachedResidences,
            clusters: _cachedClusters,
            center: _currentCenter!,
            radiusKm: _currentRadius,
            filter: _currentFilter,
            isClusterMode: _isClusterMode,
          ));
        } else {
          emit(const MapError(message: 'Résidence non trouvée'));
        }
      }
    } catch (e) {
      deboger('Erreur MapBloc.SelectMapResidence: $e');
      emit(MapError(message: 'Erreur lors de la sélection: $e'));
    }
  }

  Future<void> _onLoadResidenceDetails(
    LoadResidenceDetails event,
    Emitter<MapState> emit,
  ) async {
    try {
      final residenceDetails = await _mapService.getResidenceDetails(event.residenceId);

      if (residenceDetails != null) {
        emit(MapResidenceDetailsLoaded(
          residenceDetails: residenceDetails,
        ));
      } else {
        emit(const MapError(message: 'Détails de la résidence non trouvés'));
      }
    } catch (e) {
      deboger('Erreur MapBloc.LoadResidenceDetails: $e');
      emit(MapError(message: 'Erreur lors du chargement des détails: $e'));
    }
  }

  Future<void> _onUpdateMapCenter(
    UpdateMapCenter event,
    Emitter<MapState> emit,
  ) async {
    _currentCenter = event.center;

    emit(MapCenterUpdated(
      center: event.center,
      filter: _currentFilter,
    ));

    // Recharger les données avec le nouveau centre
    if (_isClusterMode) {
      add(LoadClusteredMapResidences(
        center: event.center,
        radiusKm: _currentRadius,
        filter: _currentFilter,
      ));
    } else {
      add(LoadFilteredMapResidences(
        center: event.center,
        radiusKm: _currentRadius,
        filter: _currentFilter,
      ));
    }
  }

  Future<void> _onUpdateMapFilter(
    UpdateMapFilter event,
    Emitter<MapState> emit,
  ) async {
    _currentFilter = event.filter;

    emit(MapFilterUpdated(
      filter: event.filter,
      center: _currentCenter!,
      radiusKm: _currentRadius,
    ));

    // Recharger les données avec le nouveau filtre
    if (_currentCenter != null) {
      if (_isClusterMode) {
        add(LoadClusteredMapResidences(
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: event.filter,
        ));
      } else {
        add(LoadFilteredMapResidences(
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: event.filter,
        ));
      }
    }
  }

  Future<void> _onRefreshMapData(
    RefreshMapData event,
    Emitter<MapState> emit,
  ) async {
    if (_currentCenter != null) {
      _cachedResidences = null;
      _cachedClusters = null;

      if (_isClusterMode) {
        add(LoadClusteredMapResidences(
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: _currentFilter,
        ));
      } else {
        add(LoadFilteredMapResidences(
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: _currentFilter,
        ));
      }
    }
  }

  Future<void> _onClearMapSelection(
    ClearMapSelection event,
    Emitter<MapState> emit,
  ) async {
    if (_cachedClusters != null) {
      emit(MapClustersLoaded(
        clusters: _cachedClusters!,
        center: _currentCenter!,
        radiusKm: _currentRadius,
        clusterRadiusKm: 0.5,
        filter: _currentFilter,
      ));
    } else if (_cachedResidences != null) {
      emit(MapResidencesLoaded(
        residences: _cachedResidences!,
        center: _currentCenter!,
        radiusKm: _currentRadius,
        filter: _currentFilter,
        isClusterMode: _isClusterMode,
      ));
    }
  }

  Future<void> _onRequestRealLocation(
    RequestRealLocation event,
    Emitter<MapState> emit,
  ) async {
    try {
      final realLocation = await _mapService.getRealCoordinates(event.residenceId);

      if (realLocation != null) {
        emit(MapRealLocationLoaded(
          residenceId: event.residenceId,
          realLocation: realLocation,
        ));
      } else {
        emit(const MapError(message: 'Localisation précise non disponible'));
      }
    } catch (e) {
      deboger('Erreur MapBloc.RequestRealLocation: $e');
      emit(MapError(message: 'Erreur lors de la récupération de la localisation: $e'));
    }
  }

  Future<void> _onToggleClusterMode(
    ToggleClusterMode event,
    Emitter<MapState> emit,
  ) async {
    _isClusterMode = event.enableClustering;

    if (_currentCenter != null) {
      if (event.enableClustering) {
        add(LoadClusteredMapResidences(
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: _currentFilter,
        ));
      } else {
        add(LoadFilteredMapResidences(
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: _currentFilter,
        ));
      }
    }
  }

  // Getters pour l'état actuel
  LatLng? get currentCenter => _currentCenter;
  double get currentRadius => _currentRadius;
  FilterCriteria? get currentFilter => _currentFilter;
  bool get isClusterMode => _isClusterMode;
}