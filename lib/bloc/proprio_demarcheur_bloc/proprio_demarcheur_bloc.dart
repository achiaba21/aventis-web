import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/proprio_demarcheur_bloc/proprio_demarcheur_event.dart';
import 'package:asfar/bloc/proprio_demarcheur_bloc/proprio_demarcheur_state.dart';
import 'package:asfar/service/model/proprietaire/proprietaire_demarcheur_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class ProprietaireDemarcheurBloc
    extends Bloc<ProprietaireDemarcheurEvent, ProprietaireDemarcheurState> {
  final ProprietaireDemarcheurService _service =
      ProprietaireDemarcheurService();

  ProprietaireDemarcheurBloc() : super(ProprietaireDemarcheurInitial()) {
    on<LoadDemarcheurs>(_onLoadDemarcheurs);
    on<LinkDemarcheur>(_onLinkDemarcheur);
    on<UnlinkDemarcheur>(_onUnlinkDemarcheur);
  }

  Future<void> _onLoadDemarcheurs(
    LoadDemarcheurs event,
    Emitter<ProprietaireDemarcheurState> emit,
  ) async {
    emit(ProprietaireDemarcheurLoading());
    try {
      final demarcheurs = await _service.getDemarcheurs();
      deboger('[ProprietaireDemarcheurBloc] démarcheurs chargés: ${demarcheurs.length}');
      emit(DemarchemursLoaded(demarcheurs));
    } catch (e) {
      ErrorHandler.logError('PROPRIO_DEMARCHEUR_LOAD', e);
      emit(ProprietaireDemarcheurError(
          ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onLinkDemarcheur(
    LinkDemarcheur event,
    Emitter<ProprietaireDemarcheurState> emit,
  ) async {
    emit(ProprietaireDemarcheurLoading());
    try {
      await _service.linkDemarcheur(event.telephone);
      deboger('[ProprietaireDemarcheurBloc] démarcheur lié: ${event.telephone}');
      emit(DemarcheurLinkSuccess("Démarcheur ajouté avec succès"));
      // Recharger la liste après liaison
      add(LoadDemarcheurs());
    } catch (e) {
      ErrorHandler.logError('PROPRIO_DEMARCHEUR_LINK', e);
      emit(ProprietaireDemarcheurError(
          ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onUnlinkDemarcheur(
    UnlinkDemarcheur event,
    Emitter<ProprietaireDemarcheurState> emit,
  ) async {
    emit(ProprietaireDemarcheurLoading());
    try {
      await _service.unlinkDemarcheur(event.id);
      deboger('[ProprietaireDemarcheurBloc] démarcheur délié: ${event.id}');
      emit(DemarcheurUnlinkSuccess());
      // Recharger la liste après déliaison
      add(LoadDemarcheurs());
    } catch (e) {
      ErrorHandler.logError('PROPRIO_DEMARCHEUR_UNLINK', e);
      emit(ProprietaireDemarcheurError(
          ErrorHandler.extractGenericErrorMessage(e)));
    }
  }
}
