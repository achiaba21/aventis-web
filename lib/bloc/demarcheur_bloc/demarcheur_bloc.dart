import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/service/model/demarcheur/demarcheur_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class DemarcheurBloc extends Bloc<DemarcheurEvent, DemarcheurState> {
  final DemarcheurService _service = DemarcheurService();

  DemarcheurBloc() : super(DemarcheurInitial()) {
    on<LoadDemarcheurAppartements>(_onLoadAppartements);
    on<LoadDemarcheurReservations>(_onLoadReservations);
    on<CreateDemarcheurReservation>(_onCreateReservation);
  }

  Future<void> _onLoadAppartements(
    LoadDemarcheurAppartements event,
    Emitter<DemarcheurState> emit,
  ) async {
    emit(DemarcheurLoading());
    try {
      final appartements = await _service.getAppartements();
      deboger('[DemarcheurBloc] appartements chargés: ${appartements.length}');
      emit(DemarcheurAppartementsLoaded(appartements));
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_BLOC_LOAD_APPARTS', e);
      emit(DemarcheurError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onLoadReservations(
    LoadDemarcheurReservations event,
    Emitter<DemarcheurState> emit,
  ) async {
    emit(DemarcheurLoading());
    try {
      final reservations = await _service.getReservations();
      deboger('[DemarcheurBloc] réservations chargées: ${reservations.length}');
      emit(DemarcheurReservationsLoaded(reservations));
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_BLOC_LOAD_RESERVATIONS', e);
      emit(DemarcheurError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onCreateReservation(
    CreateDemarcheurReservation event,
    Emitter<DemarcheurState> emit,
  ) async {
    emit(DemarcheurLoading());
    try {
      final reservation = await _service.createReservation(event.req);
      deboger('[DemarcheurBloc] réservation créée: ${reservation.reference}');
      emit(DemarcheurReservationCreated(reservation));
    } catch (e) {
      ErrorHandler.logError('DEMARCHEUR_BLOC_CREATE_RESERVATION', e);
      emit(DemarcheurError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }
}
