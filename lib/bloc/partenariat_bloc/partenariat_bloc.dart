import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_event.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_state.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/service/model/demarcheur/partenariat_demarcheur_service.dart';
import 'package:asfar/service/model/proprietaire/partenariat_proprio_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class PartenariatBloc extends Bloc<PartenariatEvent, PartenariatState> {
  final PartenariatDemarcheurService _demarcheurService =
      PartenariatDemarcheurService();
  final PartenariatProprioService _proprioService = PartenariatProprioService();

  // Cache pour préserver la liste affichée en cas d'erreur d'envoi
  List<DemandePartenariat> _cachedEnvoyees = [];
  List<DemandePartenariat> _cachedRecues = [];

  PartenariatBloc() : super(const PartenariatInitial()) {
    on<LoadDemandesEnvoyees>(_onLoadDemandesEnvoyees);
    on<EnvoyerDemande>(_onEnvoyerDemande);
    on<LoadDemandesRecues>(_onLoadDemandesRecues);
    on<AccepterDemande>(_onAccepterDemande);
    on<RefuserDemande>(_onRefuserDemande);
    on<ResetPartenariatState>(_onReset);
  }

  Future<void> _onLoadDemandesEnvoyees(
    LoadDemandesEnvoyees event,
    Emitter<PartenariatState> emit,
  ) async {
    emit(const PartenariatLoading());
    try {
      final demandes = await _demarcheurService.getDemandes();
      _cachedEnvoyees = demandes;
      deboger('[PartenariatBloc] ${demandes.length} demandes envoyées chargées');
      emit(DemandesEnvoyeesLoaded(demandes));
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_LOAD_ENVOYEES', e);
      emit(PartenariatError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onEnvoyerDemande(
    EnvoyerDemande event,
    Emitter<PartenariatState> emit,
  ) async {
    emit(const PartenariatLoading());
    try {
      await _demarcheurService.sendDemande(event.telephone);
      deboger('[PartenariatBloc] demande envoyée à ${event.telephone}');
      emit(const DemandeEnvoyeeSuccess());
      add(const LoadDemandesEnvoyees());
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_ENVOYER', e);
      emit(PartenariatError(ErrorHandler.extractGenericErrorMessage(e)));
      // Restaurer la liste : l'erreur vient de l'envoi, pas du chargement
      emit(DemandesEnvoyeesLoaded(_cachedEnvoyees));
    }
  }

  Future<void> _onLoadDemandesRecues(
    LoadDemandesRecues event,
    Emitter<PartenariatState> emit,
  ) async {
    emit(const PartenariatLoading());
    try {
      final demandes = await _proprioService.getDemandes();
      _cachedRecues = demandes;
      deboger('[PartenariatBloc] ${demandes.length} demandes reçues chargées');
      emit(DemandesRecuesLoaded(demandes));
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_LOAD_RECUES', e);
      emit(PartenariatError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onAccepterDemande(
    AccepterDemande event,
    Emitter<PartenariatState> emit,
  ) async {
    emit(const PartenariatLoading());
    try {
      await _proprioService.accepterDemande(event.id);
      deboger('[PartenariatBloc] demande ${event.id} acceptée');
      emit(const DemandeTraiteeSuccess());
      add(const LoadDemandesRecues());
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_ACCEPTER', e);
      emit(PartenariatError(ErrorHandler.extractGenericErrorMessage(e)));
      emit(DemandesRecuesLoaded(_cachedRecues));
    }
  }

  Future<void> _onRefuserDemande(
    RefuserDemande event,
    Emitter<PartenariatState> emit,
  ) async {
    emit(const PartenariatLoading());
    try {
      await _proprioService.refuserDemande(event.id);
      deboger('[PartenariatBloc] demande ${event.id} refusée');
      emit(const DemandeTraiteeSuccess());
      add(const LoadDemandesRecues());
    } catch (e) {
      ErrorHandler.logError('PARTENARIAT_REFUSER', e);
      emit(PartenariatError(ErrorHandler.extractGenericErrorMessage(e)));
      emit(DemandesRecuesLoaded(_cachedRecues));
    }
  }

  Future<void> _onReset(
    ResetPartenariatState event,
    Emitter<PartenariatState> emit,
  ) async {
    emit(const PartenariatInitial());
  }
}
