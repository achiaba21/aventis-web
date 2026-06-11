import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/config/service_locator.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/model/enumeration/appartement_status.dart';
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
  final AppartementService appartementService;
  final AppartementRepository _repository;

  AppartementBloc({
    AppartementService? service,
    AppartementRepository? repository,
  })  : appartementService = service ?? getIt<AppartementService>(),
        _repository = repository ?? getIt<AppartementRepository>(),
        super(AppartementInitial()) {
    on<LoadAppartements>(_onLoadAppartements);
    on<LoadMoreAppartements>(_onLoadMoreAppartements);
    on<RefreshAppartements>(_onRefreshAppartements);
    on<LoadAppartementsByOwner>(_onLoadAppartementsByOwner);
    on<LoadProprietaireAppartements>(_onLoadProprietaireAppartements);
    on<RefreshProprietaireAppartements>(_onRefreshProprietaireAppartements);
    on<UpdateAppartementsFromApi>(_onUpdateAppartementsFromApi);
    on<CreateAppartement>(_onCreateAppartement);
    on<UpdateAppartement>(_onUpdateAppartement);
    on<DeleteAppartement>(_onDeleteAppartement);
    on<MettreHorsLigneAppartement>(_onMettreHorsLigne);
    on<RemettreEnLigneAppartement>(_onRemettreEnLigne);
    on<ResoumetreAppartement>(_onResoumettre);
    on<AppartementStatusPushed>(_onAppartementStatusPushed);
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

  /// Charge la page suivante du feed locataire (PERF-02, scroll infini).
  ///
  /// Fusion dédoublonnée par id : si le backend ne pagine pas encore et
  /// renvoie la liste complète, aucun nouvel id n'apparaît →
  /// `hasReachedEnd = true` et l'affichage reste identique (CA1).
  /// En cas d'échec réseau, les éléments affichés sont conservés et un
  /// nouveau scroll redéclenchera l'événement (E2).
  Future<void> _onLoadMoreAppartements(
    LoadMoreAppartements event,
    Emitter<AppartementState> emit,
  ) async {
    final current = state;
    if (current is! AppartementLoaded ||
        current.source != AppartementListSource.all ||
        current.isLoadingMore ||
        current.hasReachedEnd) {
      return;
    }

    emit(current.copyWith(isLoadingMore: true));
    try {
      final nextPage = current.currentPage + 1;
      final more = await _repository.fetchMoreAppartements(nextPage);

      final knownIds = current.appartements.map((a) => a.id).toSet();
      final fresh = more.where((a) => !knownIds.contains(a.id)).toList();

      emit(current.copyWith(
        appartements:
            fresh.isEmpty ? null : [...current.appartements, ...fresh],
        isLoadingMore: false,
        hasReachedEnd: fresh.isEmpty,
        currentPage: fresh.isEmpty ? null : nextPage,
      ));
    } catch (e) {
      deboger(['[AppartementBloc] LoadMore échoué (page conservée):', e]);
      emit(current.copyWith(isLoadingMore: false));
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

  // ==================== MODÉRATION (actions propriétaire) ====================

  Future<void> _onMettreHorsLigne(
    MettreHorsLigneAppartement event,
    Emitter<AppartementState> emit,
  ) {
    return _changeStatus(
      emit,
      () => _repository.mettreHorsLigne(event.appartementId),
      'Annonce mise hors ligne',
    );
  }

  Future<void> _onRemettreEnLigne(
    RemettreEnLigneAppartement event,
    Emitter<AppartementState> emit,
  ) {
    return _changeStatus(
      emit,
      () => _repository.remettreEnLigne(event.appartementId),
      'Annonce remise en ligne',
    );
  }

  Future<void> _onResoumettre(
    ResoumetreAppartement event,
    Emitter<AppartementState> emit,
  ) {
    return _changeStatus(
      emit,
      () => _repository.resoumettre(event.appartementId),
      'Annonce resoumise à la modération',
    );
  }

  /// Exécute un changement de statut (modération) puis émet la liste
  /// rafraîchie depuis le cache avec un message de succès one-shot. En cas
  /// d'échec, relaie le message backend via `AppartementError`.
  Future<void> _changeStatus(
    Emitter<AppartementState> emit,
    Future<Appartement> Function() action,
    String successMessage,
  ) async {
    final current = state.appartements;
    emit(AppartementLoading(appartements: current));
    try {
      await action();
      emit(AppartementLoaded(
        _repository.getCachedAppartements(),
        source: AppartementListSource.proprietaire,
        transientMessage: successMessage,
      ));
    } catch (e) {
      ErrorHandler.logError("CHANGE_STATUS_APPARTEMENT", e);
      emit(AppartementError(
        ErrorHandler.extractGenericErrorMessage(e),
        appartements: current,
      ));
    }
  }

  /// Push temps réel du statut d'une annonce (verdict admin). Patche l'item
  /// dans la liste courante sans refetch. No-op si l'annonce n'est pas dans la
  /// liste affichée (ex. on est sur le feed locataire) — l'écran proprio
  /// rechargera de toute façon le bon statut à sa prochaine ouverture.
  void _onAppartementStatusPushed(
    AppartementStatusPushed event,
    Emitter<AppartementState> emit,
  ) {
    final id = event.appartementId;
    if (id == null) return;
    final current = state.appartements;
    final index = current.indexWhere((a) => a.id == id);
    if (index == -1) {
      deboger(
          '[AppartementBloc] push statut: annonce $id absente de la liste, ignoré');
      return;
    }
    final newStatus =
        AppartementStatusExtension.fromString(event.nouveauStatus);
    final updated = List<Appartement>.from(current);
    updated[index] = updated[index].copyWith(status: newStatus);
    final base = state;
    emit(AppartementLoaded(
      updated,
      source: base is AppartementLoaded
          ? base.source
          : AppartementListSource.proprietaire,
      ownerId: base is AppartementLoaded ? base.ownerId : null,
    ));
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
