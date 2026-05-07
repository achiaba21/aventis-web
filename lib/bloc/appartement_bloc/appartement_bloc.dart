import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/service/repository/appartement_repository.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour la gestion des appartements
///
/// Utilise AppartementRepository avec pattern cache-first :
/// 1. Charge depuis le cache Hive immédiatement
/// 2. Rafraîchit depuis l'API en arrière-plan
/// 3. Émet un nouvel état quand les données API arrivent
class AppartementBloc extends Bloc<AppartementEvent, AppartementState> {
  late AppartementService appartementService;
  final AppartementRepository _repository = AppartementRepository();

  AppartementBloc() : super(AppartementInitial()) {
    appartementService = AppartementService();

    on<LoadAppartements>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        final appartements = await appartementService.getAppartements();
        deboger(["appartements :", appartements]);
        emit(AppartementLoaded(appartements));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message, appartements: currentAppartements));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération", appartements: currentAppartements));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue", appartements: currentAppartements));
        deboger(e);
      }
    });

    on<RefreshAppartements>((event, emit) async {
      final currentAppartements = state.appartements;
      try {
        final appartements = await appartementService.getAppartements();
        emit(AppartementLoaded(appartements));
      } on CustomException catch (e) {
        emit(AppartementError(e.message, appartements: currentAppartements));
      } on DioException catch (e) {
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération", appartements: currentAppartements));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue", appartements: currentAppartements));
        deboger(e);
      }
    });

    on<LoadAppartementsByOwner>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        final appartements = await appartementService.getAppartementsByOwner(event.proprietaireId);
        deboger(["appartements by owner :", appartements]);
        emit(AppartementsByOwnerLoaded(appartements, event.proprietaireId));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message, appartements: currentAppartements));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération", appartements: currentAppartements));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue", appartements: currentAppartements));
        deboger(e);
      }
    });

    on<LoadFilteredAppartements>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        final appartements = await appartementService.getFilteredAppartements(event.criteria);
        deboger(["filtered appartements :", appartements]);
        emit(FilteredAppartementsLoaded(appartements, event.criteria));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message, appartements: currentAppartements));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération", appartements: currentAppartements));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue", appartements: currentAppartements));
        deboger(e);
      }
    });

    on<LoadFilterOptions>((event, emit) async {
      final currentAppartements = state.appartements;
      try {
        final options = await appartementService.getFilterOptions();
        deboger(["filter options :", options]);
        emit(FilterOptionsLoaded(options, currentAppartements));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message, appartements: currentAppartements));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération", appartements: currentAppartements));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue", appartements: currentAppartements));
        deboger(e);
      }
    });

    on<ClearFilters>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        final appartements = await appartementService.getAppartements();
        deboger(["clear filters - all appartements :", appartements]);
        emit(AppartementLoaded(appartements));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message, appartements: currentAppartements));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération", appartements: currentAppartements));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue", appartements: currentAppartements));
        deboger(e);
      }
    });

    on<LoadProprietaireAppartements>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        // Pattern cache-first : retourne le cache immédiatement
        // puis rafraîchit en arrière-plan
        final appartements = await _repository.getAppartements(
          forceRefresh: false,
          onApiData: (apiAppartements) {
            // Quand les données API arrivent, mettre à jour l'état
            add(UpdateAppartementsFromApi(apiAppartements));
          },
        );
        deboger(["propriétaire appartements (cache):", appartements.length]);
        emit(ProprietaireAppartementsLoaded(appartements));
      } catch (e) {
        ErrorHandler.logError("LOAD_PROPRIETAIRE_APPARTEMENTS", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(AppartementError(errorMessage, appartements: currentAppartements));
      }
    });

    /// Met à jour l'état avec les données fraîches de l'API
    on<UpdateAppartementsFromApi>((event, emit) async {
      deboger(['[AppartementBloc] Mise à jour avec données API: ${event.appartements.length} appartements']);
      emit(ProprietaireAppartementsLoaded(event.appartements));
    });

    /// Rafraîchit les appartements du propriétaire depuis l'API
    on<RefreshProprietaireAppartements>((event, emit) async {
      final currentAppartements = state.appartements;
      try {
        // Forcer le rechargement depuis l'API
        final appartements = await _repository.getAppartements(forceRefresh: true);
        deboger(["appartements rafraîchis depuis l'API :", appartements.length]);
        emit(ProprietaireAppartementsLoaded(appartements));
      } catch (e) {
        ErrorHandler.logError("REFRESH_PROPRIETAIRE_APPARTEMENTS", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(AppartementError(errorMessage, appartements: currentAppartements));
      }
    });

    // ==================== CRUD HANDLERS (Propriétaire) ====================

    /// Crée un nouvel appartement via le Repository
    on<CreateAppartement>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        // Utiliser la méthode avec ou sans images selon le cas
        if (event.images != null && event.images!.isNotEmpty) {
          await _repository.createAppartementWithImages(event.appartement, event.images!);
        } else {
          await _repository.saveAppartement(event.appartement);
        }
        deboger(["appartement créé avec succès"]);

        // Le cache a été mis à jour par le repository
        final appartements = _repository.getCachedAppartements();

        // DOUBLE ÉMISSION : 1. Message de succès temporaire
        emit(AppartementOperationSuccess("Appartement créé avec succès", appartements));

        // DOUBLE ÉMISSION : 2. État stable pour actualisation automatique
        await Future.delayed(const Duration(milliseconds: 300));
        emit(ProprietaireAppartementsLoaded(List.from(appartements)));

        deboger(["état stable émis - liste actualisée"]);
      } catch (e) {
        ErrorHandler.logError("CREATE_APPARTEMENT", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(AppartementError(errorMessage, appartements: currentAppartements));
      }
    });

    /// Met à jour un appartement existant via le Repository
    on<UpdateAppartement>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        // Utiliser updateAppartementWithImages pour gérer les photos
        await _repository.updateAppartementWithImages(
          event.appartement.id!,
          event.appartement,
          event.images ?? [],
          photosToDelete: event.photosToDelete,
        );
        deboger(["appartement mis à jour avec succès"]);

        // Le cache a été mis à jour par le repository
        final appartements = _repository.getCachedAppartements();

        // DOUBLE ÉMISSION : 1. Message de succès temporaire
        emit(AppartementOperationSuccess("Appartement modifié avec succès", appartements));

        // DOUBLE ÉMISSION : 2. État stable pour actualisation automatique
        await Future.delayed(const Duration(milliseconds: 300));
        emit(ProprietaireAppartementsLoaded(List.from(appartements)));

        deboger(["état stable émis - liste actualisée"]);
      } catch (e) {
        ErrorHandler.logError("UPDATE_APPARTEMENT", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(AppartementError(errorMessage, appartements: currentAppartements));
      }
    });

    /// Supprime un appartement via le Repository
    on<DeleteAppartement>((event, emit) async {
      final currentAppartements = state.appartements;
      emit(AppartementLoading(appartements: currentAppartements));
      try {
        await _repository.deleteAppartement(event.appartementId);
        deboger(["appartement supprimé avec succès"]);

        // Le cache a été mis à jour par le repository
        final appartements = _repository.getCachedAppartements();

        // DOUBLE ÉMISSION : 1. Message de succès temporaire
        emit(AppartementOperationSuccess("Appartement supprimé avec succès", appartements));

        // DOUBLE ÉMISSION : 2. État stable pour actualisation automatique
        await Future.delayed(const Duration(milliseconds: 300));
        emit(ProprietaireAppartementsLoaded(List.from(appartements)));

        deboger(["état stable émis - liste actualisée"]);
      } catch (e) {
        ErrorHandler.logError("DELETE_APPARTEMENT", e);
        final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
        emit(AppartementError(errorMessage, appartements: currentAppartements));
      }
    });

    // ==================== SYNCHRONISATION ====================

    /// Synchronise les appartements depuis une liste préchargée
    on<SyncFromResidences>((event, emit) {
      deboger(['[AppartementBloc] Sync préchargement: ${event.appartements.length} appartements']);
      emit(AppartementLoaded(event.appartements));
    });

    // ==================== RÉINITIALISATION ====================

    /// Réinitialise le BLoC à son état Initial
    /// Utilisé lors d'une nouvelle session utilisateur pour garantir l'affichage des skeletons
    on<ResetAppartementState>((event, emit) {
      deboger(['[AppartementBloc] Réinitialisation à l\'état Initial']);
      emit(AppartementInitial());
    });
  }
}