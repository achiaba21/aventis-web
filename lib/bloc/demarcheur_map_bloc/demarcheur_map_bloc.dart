import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_event.dart';
import 'package:asfar/bloc/demarcheur_map_bloc/demarcheur_map_state.dart';
import 'package:asfar/model/map/map_filtered_response.dart';
import 'package:asfar/service/model/map/map_service.dart';
import 'package:asfar/util/function.dart';

/// BLoC carte démarcheur — V9.7d.
///
/// Orchestrateur du flow Yango pour le rôle Démarcheur. Réutilise `MapService`
/// (endpoints `/api/map/appartements/filtered` et `/api/map/search`) ; le scope
/// au réseau partenaires est garanti côté serveur via le token Bearer.
///
/// Différences vs `MapBloc` locataire (SOLID — séparation par rôle) :
/// - Pas de `RequestRealLocation` : le démarcheur ne réserve pas.
/// - Pas de `UpdateMapFilter` : `ListingFilters` reste local au screen
///   (`ListingMapPane.activeFilters`).
/// - Pas de `SelectMapAppartement` / `LoadAppartementDetails` : tap pin →
///   navigation directe vers `DemarcheurAppartDetailScreen` (callback parent).
class DemarcheurMapBloc
    extends Bloc<DemarcheurMapEvent, DemarcheurMapState> {
  final MapService _mapService;

  LatLng? _currentCenter;
  double _currentRadius = 10.0;

  DemarcheurMapBloc({MapService? mapService})
      : _mapService = mapService ?? MapService(),
        super(const DemarcheurMapInitial()) {
    on<LoadDemarcheurMapAppartements>(_onLoadAppartements);
    on<UpdateDemarcheurMapCenter>(_onUpdateCenter);
    on<SearchPlaceDemarcheur>(_onSearchPlace);
    on<RefreshDemarcheurMap>(_onRefresh);
    on<ResetDemarcheurMapState>(_onReset);
  }

  Future<void> _onLoadAppartements(
    LoadDemarcheurMapAppartements event,
    Emitter<DemarcheurMapState> emit,
  ) async {
    emit(const DemarcheurMapLoading());

    try {
      _currentCenter = event.center;
      _currentRadius = event.radiusKm;

      final MapFilteredResponse response =
          await _mapService.getFilteredMapAppartements(
        center: event.center,
        radiusKm: event.radiusKm,
      );

      final appartements = response.appartements;

      if (appartements.isEmpty) {
        emit(DemarcheurMapEmpty(
          message: 'Aucun logement partenaire dans cette zone',
          center: event.center,
          radiusKm: event.radiusKm,
          zoneName: response.zoneName,
        ));
      } else {
        emit(DemarcheurMapAppartementsLoaded(
          appartements: appartements,
          center: event.center,
          radiusKm: event.radiusKm,
          zoneName: response.zoneName,
        ));
      }
    } catch (e) {
      deboger('Erreur DemarcheurMapBloc.LoadDemarcheurMapAppartements: $e');
      emit(DemarcheurMapError(
        message: 'Erreur lors du chargement des logements: $e',
      ));
    }
  }

  Future<void> _onUpdateCenter(
    UpdateDemarcheurMapCenter event,
    Emitter<DemarcheurMapState> emit,
  ) async {
    _currentCenter = event.center;

    emit(DemarcheurMapCenterUpdated(center: event.center));

    add(LoadDemarcheurMapAppartements(
      center: event.center,
      radiusKm: _currentRadius,
    ));
  }

  Future<void> _onSearchPlace(
    SearchPlaceDemarcheur event,
    Emitter<DemarcheurMapState> emit,
  ) async {
    emit(const DemarcheurMapPlaceSearchLoading());

    try {
      final result = await _mapService.searchPlace(event.query);
      emit(DemarcheurMapPlaceSearchSuccess(result: result));
    } catch (e) {
      deboger('Erreur DemarcheurMapBloc.SearchPlaceDemarcheur: $e');
      final message = e.toString().replaceFirst('Exception: ', '');
      emit(DemarcheurMapPlaceSearchError(message: message));
    }
  }

  Future<void> _onRefresh(
    RefreshDemarcheurMap event,
    Emitter<DemarcheurMapState> emit,
  ) async {
    if (_currentCenter == null) return;
    add(LoadDemarcheurMapAppartements(
      center: _currentCenter!,
      radiusKm: _currentRadius,
    ));
  }

  void _onReset(
    ResetDemarcheurMapState event,
    Emitter<DemarcheurMapState> emit,
  ) {
    deboger(['[DemarcheurMapBloc] Réinitialisation à l\'état Initial']);
    _currentCenter = null;
    _currentRadius = 10.0;
    emit(const DemarcheurMapInitial());
  }

  LatLng? get currentCenter => _currentCenter;
  double get currentRadius => _currentRadius;
}
