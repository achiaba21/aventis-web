import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/model/demarcheur/demarcheur_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// BLoC du rôle Démarcheur — porte un état unique [DemarcheurDataLoaded]
/// qui agrège les appartements partenaires et les réservations référées.
///
/// Les caches privés (`_appartements`, `_reservations`) survivent aux
/// transitions de state pour qu'un load n'écrase pas l'autre (cf. dashboard
/// qui dispatche simultanément `LoadDemarcheurAppartements` et
/// `LoadDemarcheurReservations`).
class DemarcheurBloc extends Bloc<DemarcheurEvent, DemarcheurState> {
  final DemarcheurService _service = DemarcheurService();

  List<Appartement> _appartements = const [];
  List<Reservation> _reservations = const [];

  DemarcheurBloc() : super(const DemarcheurInitial()) {
    on<LoadDemarcheurAppartements>(_onLoadAppartements);
    on<LoadDemarcheurReservations>(_onLoadReservations);
    on<CreateDemarcheurReservation>(_onCreateReservation);
  }

  DemarcheurDataLoaded _snapshot() => DemarcheurDataLoaded(
        appartements: _appartements,
        reservations: _reservations,
      );

  Future<void> _onLoadAppartements(
    LoadDemarcheurAppartements event,
    Emitter<DemarcheurState> emit,
  ) async {
    if (_appartements.isEmpty && _reservations.isEmpty) {
      emit(const DemarcheurLoading());
    }
    try {
      _appartements = await _service.getAppartements();
      deboger('[DemarcheurBloc] appartements chargés: ${_appartements.length}');
      emit(_snapshot());
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_BLOC_LOAD_APPARTS', e);
      emit(DemarcheurError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onLoadReservations(
    LoadDemarcheurReservations event,
    Emitter<DemarcheurState> emit,
  ) async {
    deboger('🐛[DEMANDE] LoadDemarcheurReservations déclenché (refetch liste)');
    if (_appartements.isEmpty && _reservations.isEmpty) {
      emit(const DemarcheurLoading());
    }
    try {
      _reservations = await _service.getReservations();
      deboger('[DemarcheurBloc] réservations chargées: ${_reservations.length}');
      emit(_snapshot());
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_BLOC_LOAD_RESERVATIONS', e);
      emit(DemarcheurError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onCreateReservation(
    CreateDemarcheurReservation event,
    Emitter<DemarcheurState> emit,
  ) async {
    emit(const DemarcheurLoading());
    try {
      final reservation = await _service.createReservation(event.req);
      deboger(
          '🐛[DEMANDE] bloc create reçu → id=${reservation.id}, ref=${reservation.reference}');
      emit(DemarcheurReservationCreated(reservation));
      // Pas d'insert optimiste de l'objet de réponse (souvent partiel → id null
      // → carte « #0 »). On recharge la liste autoritative depuis l'endpoint
      // liste (objets complets + dédupliqués).
      _reservations = await _service.getReservations();
      deboger(
          '🐛[DEMANDE] bloc après refetch: ${_reservations.length} (ids=${_reservations.map((e) => e.id).toList()})');
      emit(_snapshot());
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_BLOC_CREATE_RESERVATION', e);
      emit(DemarcheurError(ErrorHandler.extractGenericErrorMessage(e)));
      emit(_snapshot());
    }
  }
}
