import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appartement_list_source.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/service/repository/appartement_repository.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour la gestion des appartements.
///
/// Pattern cache-first via `AppartementRepository` aussi bien côté locataire
/// (feed découverte) que côté propriétaire (mes biens). Le filtrage est géré
/// par `AppartementFilterCubit` dédié.
///
/// Le CRUD côté proprio émet un `AppartementLoaded` unique avec
/// `transientMessage` — plus de `Future.delayed` / double émission.
class AppartementBloc extends Bloc<AppartementEvent, AppartementState> {
  late AppartementService appartementService;
  final AppartementRepository _repository = AppartementRepository();

  AppartementBloc() : super(AppartementInitial()) {
    appartementService = AppartementService();

    on<LoadAppartements>(_onLoadAppartements);
    on<RefreshAppartements>(_onRefreshAppartements);
    on<LoadAppartementsByOwner>(_onLoadAppartementsByOwner);
    on<LoadProprietaireAppartements>(_onLoadProprietaireAppartements);
    on<RefreshProprietaireAppartements>(_onRefreshProprietaireAppartements);
    on<UpdateAppartementsFromApi>(_onUpdateAppartementsFromApi);
    on<CreateAppartement>(_onCreateAppartement);
    on<UpdateAppartement>(_onUpdateAppartement);
    on<DeleteAppartement>(_onDeleteAppartement);
    on<SyncFromResidences>(_onSyncFromResidences);
    on<ResetAppartementState>(_onResetAppartementState);
  }

  // ==================== CHARGEMENT LOCATAIRE (cache-first) ====================

  Future<void> _onLoadAppartements(
    LoadAppartements event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    emit(AppartementLoading(appartements: current));
    try {
      final appartements = await _repository.getAllAppartements(
        forceRefresh: false,
        onApiData: (apiAppartements) {
          add(UpdateAppartementsFromApi(apiAppartements));
        },
      );
      emit(AppartementLoaded(
        appartements,
        source: AppartementListSource.all,
      ));
    } catch (e) {
      _emitError(emit, e, current);
    }
  }

  Future<void> _onRefreshAppartements(
    RefreshAppartements event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    try {
      final appartements = await _repository.getAllAppartements(
        forceRefresh: true,
      );
      emit(AppartementLoaded(
        appartements,
        source: AppartementListSource.all,
      ));
    } catch (e) {
      _emitError(emit, e, current);
    }
  }

  Future<void> _onLoadAppartementsByOwner(
    LoadAppartementsByOwner event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    emit(AppartementLoading(appartements: current));
    try {
      final appartements =
          await appartementService.getAppartementsByOwner(event.proprietaireId);
      emit(AppartementLoaded(
        appartements,
        source: AppartementListSource.byOwner,
        ownerId: event.proprietaireId,
      ));
    } catch (e) {
      _emitError(emit, e, current);
    }
  }

  // ==================== CHARGEMENT PROPRIO (cache-first) ====================

  Future<void> _onLoadProprietaireAppartements(
    LoadProprietaireAppartements event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    emit(AppartementLoading(appartements: current));
    try {
      final appartements = await _repository.getAppartements(
        forceRefresh: false,
        onApiData: (apiAppartements) {
          add(UpdateAppartementsFromApi(apiAppartements));
        },
      );
      emit(AppartementLoaded(
        appartements,
        source: AppartementListSource.proprietaire,
      ));
    } catch (e) {
      _emitError(emit, e, current);
    }
  }

  Future<void> _onRefreshProprietaireAppartements(
    RefreshProprietaireAppartements event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    try {
      final appartements =
          await _repository.getAppartements(forceRefresh: true);
      emit(AppartementLoaded(
        appartements,
        source: AppartementListSource.proprietaire,
      ));
    } catch (e) {
      _emitError(emit, e, current);
    }
  }

  void _onUpdateAppartementsFromApi(
    UpdateAppartementsFromApi event,
    Emitter<AppartementState> emit,
  ) {
    final currentSource = state is AppartementLoaded
        ? (state as AppartementLoaded).source
        : AppartementListSource.proprietaire;
    final currentOwnerId = state is AppartementLoaded
        ? (state as AppartementLoaded).ownerId
        : null;
    emit(AppartementLoaded(
      event.appartements,
      source: currentSource,
      ownerId: currentOwnerId,
    ));
  }

  // ==================== CRUD ====================

  Future<void> _onCreateAppartement(
    CreateAppartement event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    emit(AppartementLoading(appartements: current));
    try {
      if (event.images != null && event.images!.isNotEmpty) {
        await _repository.createAppartementWithImages(
          event.appartement,
          event.images!,
        );
      } else {
        await _repository.saveAppartement(event.appartement);
      }
      emit(AppartementLoaded(
        _repository.getCachedAppartements(),
        source: AppartementListSource.proprietaire,
        transientMessage: 'Appartement créé avec succès',
      ));
    } catch (e) {
      ErrorHandler.logError("CREATE_APPARTEMENT", e);
      emit(AppartementError(
        ErrorHandler.extractGenericErrorMessage(e),
        appartements: current,
      ));
    }
  }

  Future<void> _onUpdateAppartement(
    UpdateAppartement event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    emit(AppartementLoading(appartements: current));
    try {
      await _repository.updateAppartementWithImages(
        event.appartement.id!,
        event.appartement,
        event.images ?? [],
        photosToDelete: event.photosToDelete,
      );
      emit(AppartementLoaded(
        _repository.getCachedAppartements(),
        source: AppartementListSource.proprietaire,
        transientMessage: 'Appartement modifié avec succès',
      ));
    } catch (e) {
      ErrorHandler.logError("UPDATE_APPARTEMENT", e);
      emit(AppartementError(
        ErrorHandler.extractGenericErrorMessage(e),
        appartements: current,
      ));
    }
  }

  Future<void> _onDeleteAppartement(
    DeleteAppartement event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state.appartements;
    emit(AppartementLoading(appartements: current));
    try {
      await _repository.deleteAppartement(event.appartementId);
      emit(AppartementLoaded(
        _repository.getCachedAppartements(),
        source: AppartementListSource.proprietaire,
        transientMessage: 'Appartement supprimé avec succès',
      ));
    } catch (e) {
      ErrorHandler.logError("DELETE_APPARTEMENT", e);
      emit(AppartementError(
        ErrorHandler.extractGenericErrorMessage(e),
        appartements: current,
      ));
    }
  }

  // ==================== SYNC / RESET ====================

  void _onSyncFromResidences(
    SyncFromResidences event,
    Emitter<AppartementState> emit,
  ) {
    emit(AppartementLoaded(
      event.appartements,
      source: AppartementListSource.proprietaire,
    ));
  }

  void _onResetAppartementState(
    ResetAppartementState event,
    Emitter<AppartementState> emit,
  ) {
    emit(AppartementInitial());
  }

  // ==================== Helpers ====================

  void _emitError(
    Emitter<AppartementState> emit,
    Object e,
    List<Appartement> current,
  ) {
    String msg;
    if (e is CustomException) {
      msg = e.message;
    } else if (e is DioException) {
      msg = e.response?.data?.toString() ?? 'Erreur de récupération';
    } else {
      msg = 'Une erreur est survenue';
    }
    deboger(['[AppartementBloc] $msg', e]);
    emit(AppartementError(msg, appartements: current));
  }
}
