import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/map_bloc/map_event.dart';
import 'package:asfar/bloc/map_bloc/map_state.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/map/map_appartement.dart';
import 'package:asfar/service/model/map/map_service.dart';
import 'package:asfar/util/function.dart';

/// BLoC de la carte locataire — V9.7b.
///
/// 1 marker = 1 appartement (suppression de la notion de résidence agrégée).
/// Coordonnées toujours obfusquées en browse ; révélation post-réservation
/// uniquement via `RequestRealLocation`.
class MapBloc extends Bloc<MapEvent, MapState> {
  final MapService _mapService = MapService();

  LatLng? _currentCenter;
  double _currentRadius = 10.0;
  FilterCriteria? _currentFilter;
  List<MapAppartement>? _cachedAppartements;

  MapBloc() : super(const MapInitial()) {
    on<LoadFilteredMapAppartements>(_onLoadFilteredMapAppartements);
    on<SelectMapAppartement>(_onSelectMapAppartement);
    on<LoadAppartementDetails>(_onLoadAppartementDetails);
    on<UpdateMapCenter>(_onUpdateMapCenter);
    on<UpdateMapFilter>(_onUpdateMapFilter);
    on<RefreshMapData>(_onRefreshMapData);
    on<ClearMapSelection>(_onClearMapSelection);
    on<RequestRealLocation>(_onRequestRealLocation);
    on<ResetMapState>(_onResetMapState);
  }

  Future<void> _onLoadFilteredMapAppartements(
    LoadFilteredMapAppartements event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapLoading());

    try {
      _currentCenter = event.center;
      _currentRadius = event.radiusKm;
      _currentFilter = event.filter;

      final appartements = await _mapService.getFilteredMapAppartements(
        center: event.center,
        radiusKm: event.radiusKm,
        filter: event.filter,
      );

      _cachedAppartements = appartements;

      if (appartements.isEmpty) {
        emit(MapEmpty(
          message: "Aucun appartement ne correspond à vos critères",
          center: event.center,
          radiusKm: event.radiusKm,
          filter: event.filter,
        ));
      } else {
        emit(MapAppartementsLoaded(
          appartements: appartements,
          center: event.center,
          radiusKm: event.radiusKm,
          filter: event.filter,
        ));
      }
    } catch (e) {
      deboger('Erreur MapBloc.LoadFilteredMapAppartements: $e');
      emit(MapNetworkError(
        message: 'Erreur lors du chargement des appartements: $e',
      ));
    }
  }

  Future<void> _onSelectMapAppartement(
    SelectMapAppartement event,
    Emitter<MapState> emit,
  ) async {
    try {
      MapAppartement? selected;

      if (_cachedAppartements != null) {
        for (final a in _cachedAppartements!) {
          if (a.id == event.appartementId) {
            selected = a;
            break;
          }
        }
      }

      if (selected != null && _currentCenter != null) {
        emit(MapAppartementSelected(
          selectedAppartement: selected,
          allAppartements: _cachedAppartements,
          center: _currentCenter!,
          radiusKm: _currentRadius,
          filter: _currentFilter,
        ));
      } else {
        emit(const MapError(message: 'Appartement non trouvé'));
      }
    } catch (e) {
      deboger('Erreur MapBloc.SelectMapAppartement: $e');
      emit(MapError(message: 'Erreur lors de la sélection: $e'));
    }
  }

  Future<void> _onLoadAppartementDetails(
    LoadAppartementDetails event,
    Emitter<MapState> emit,
  ) async {
    try {
      MapAppartement? appartement;
      if (_cachedAppartements != null) {
        for (final a in _cachedAppartements!) {
          if (a.id == event.appartementId) {
            appartement = a;
            break;
          }
        }
      }

      if (appartement != null) {
        emit(MapAppartementDetailsLoaded(appartementDetails: appartement));
      } else {
        emit(const MapError(message: 'Détails de l\'appartement non trouvés'));
      }
    } catch (e) {
      deboger('Erreur MapBloc.LoadAppartementDetails: $e');
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

    add(LoadFilteredMapAppartements(
      center: event.center,
      radiusKm: _currentRadius,
      filter: _currentFilter,
    ));
  }

  Future<void> _onUpdateMapFilter(
    UpdateMapFilter event,
    Emitter<MapState> emit,
  ) async {
    _currentFilter = event.filter;

    if (_currentCenter == null) return;

    emit(MapFilterUpdated(
      filter: event.filter,
      center: _currentCenter!,
      radiusKm: _currentRadius,
    ));

    add(LoadFilteredMapAppartements(
      center: _currentCenter!,
      radiusKm: _currentRadius,
      filter: event.filter,
    ));
  }

  Future<void> _onRefreshMapData(
    RefreshMapData event,
    Emitter<MapState> emit,
  ) async {
    if (_currentCenter == null) return;
    _cachedAppartements = null;
    add(LoadFilteredMapAppartements(
      center: _currentCenter!,
      radiusKm: _currentRadius,
      filter: _currentFilter,
    ));
  }

  Future<void> _onClearMapSelection(
    ClearMapSelection event,
    Emitter<MapState> emit,
  ) async {
    if (_cachedAppartements == null || _currentCenter == null) return;
    emit(MapAppartementsLoaded(
      appartements: _cachedAppartements!,
      center: _currentCenter!,
      radiusKm: _currentRadius,
      filter: _currentFilter,
    ));
  }

  Future<void> _onRequestRealLocation(
    RequestRealLocation event,
    Emitter<MapState> emit,
  ) async {
    try {
      final realLocation =
          await _mapService.getRealCoordinates(event.appartementId);

      if (realLocation != null) {
        emit(MapRealLocationLoaded(
          appartementId: event.appartementId,
          realLocation: realLocation,
        ));
      } else {
        emit(const MapError(message: 'Localisation précise non disponible'));
      }
    } catch (e) {
      deboger('Erreur MapBloc.RequestRealLocation: $e');
      emit(MapError(
        message: 'Erreur lors de la récupération de la localisation: $e',
      ));
    }
  }

  // ==================== RÉINITIALISATION ====================

  void _onResetMapState(
    ResetMapState event,
    Emitter<MapState> emit,
  ) {
    deboger(['[MapBloc] Réinitialisation à l\'état Initial']);
    _currentCenter = null;
    _currentRadius = 10.0;
    _currentFilter = null;
    _cachedAppartements = null;
    emit(const MapInitial());
  }

  // Getters pour l'état actuel
  LatLng? get currentCenter => _currentCenter;
  double get currentRadius => _currentRadius;
  FilterCriteria? get currentFilter => _currentFilter;
}
