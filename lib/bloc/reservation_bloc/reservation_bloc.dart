import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/config/service_locator.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/service/model/booking/reservation_service.dart';
import 'package:asfar/service/repository/reservation_repository.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour la gestion des réservations
///
/// Utilise ReservationRepository avec pattern cache-first :
/// 1. Charge depuis le cache Hive immédiatement
/// 2. Rafraîchit depuis l'API en arrière-plan
/// 3. Émet un nouvel état quand les données API arrivent
class ReservationBloc extends Bloc<ReservationEvent, ReservationState> {
  final ReservationService reservationService;
  final ReservationRepository _repository;

  ReservationBloc({
    ReservationService? service,
    ReservationRepository? repository,
  })  : reservationService = service ?? getIt<ReservationService>(),
        _repository = repository ?? getIt<ReservationRepository>(),
        super(ReservationInitial()) {
    on<SetReservationReq>((event, emit) {
      deboger(['SetReservationReq:', event.reservationReq]);
      emit(ReservationReqUpdated(event.reservationReq, reservations: state.reservations));
    });

    on<ClearReservationReq>((event, emit) {
      deboger('ClearReservationReq');
      emit(ReservationReqUpdated(null, reservations: state.reservations));
    });

    on<CreateReservation>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        final reservation = await reservationService.createReservation(event.reservationReq);
        deboger(['Réservation créée avec succès:', reservation]);
        emit(ReservationCreated(reservation, currentReq: currentReq, reservations: currentReservations));
      } on CustomException catch (e) {
        deboger(['CustomException:', e]);
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        deboger(['DioException:', e]);
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de création de réservation", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        deboger(['Exception générale:', e]);
        emit(ReservationError("Une erreur est survenue lors de la création de la réservation", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<CreateManualReservation>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        final reservation = await reservationService.createManualReservation(event.req);
        deboger(['Réservation manuelle créée avec succès:', reservation]);
        emit(ReservationManuelleCreated(reservation, currentReq: currentReq, reservations: currentReservations));
        // Rafraîchir la liste des réservations propriétaire
        add(LoadProprietaireReservations());
      } on CustomException catch (e) {
        deboger(['CustomException:', e]);
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        deboger(['DioException:', e]);
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de création de réservation manuelle", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        deboger(['Exception générale:', e]);
        emit(ReservationError("Une erreur est survenue lors de la création de la réservation", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<LoadUserReservations>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        // Pattern cache-first : retourne le cache immédiatement
        // puis rafraîchit en arrière-plan
        final result = await _repository.getUserReservations(
          forceRefresh: false,
          onApiData: (apiReservations) {
            // Quand les données API arrivent, mettre à jour l'état
            add(UpdateReservationsFromApi(apiReservations));
          },
        );
        deboger(['[ReservationBloc] User reservations (cache: ${result.isFromCache}): ${result.reservations.length}']);
        emit(ReservationLoaded(result.reservations, currentReq: currentReq));
      } catch (e) {
        deboger(['[ReservationBloc] Erreur LoadUserReservations: $e']);
        emit(ReservationError("Erreur lors du chargement des réservations", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<LoadProprietaireReservations>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        // Pattern cache-first : retourne le cache immédiatement
        // puis rafraîchit en arrière-plan
        final result = await _repository.getProprietaireReservations(
          forceRefresh: false,
          onApiData: (apiReservations) {
            // Quand les données API arrivent, mettre à jour l'état
            add(UpdateReservationsFromApi(apiReservations));
          },
        );
        deboger(['[ReservationBloc] Proprio reservations (cache: ${result.isFromCache}): ${result.reservations.length}']);
        emit(ReservationLoaded(result.reservations, currentReq: currentReq));
      } catch (e) {
        deboger(['[ReservationBloc] Erreur LoadProprietaireReservations: $e']);
        emit(ReservationError("Erreur lors du chargement des réservations", currentReq: currentReq, reservations: currentReservations));
      }
    });

    // PERF-02 : page suivante des réservations (support sans câblage UI).
    // Fusion dédoublonnée par référence — sans backend paginé, aucune
    // nouvelle référence n'apparaît → hasReachedEnd, affichage inchangé (CA1).
    on<LoadMoreReservations>((event, emit) async {
      final current = state;
      if (current is! ReservationLoaded ||
          current.isLoadingMore ||
          current.hasReachedEnd) {
        return;
      }
      emit(current.copyWith(isLoadingMore: true));
      try {
        final nextPage = current.currentPage + 1;
        final more = await _repository.fetchMoreReservations(
          nextPage,
          isProprietaire: event.isProprietaire,
        );
        final known = current.reservations.map((r) => r.reference).toSet();
        final fresh =
            more.where((r) => !known.contains(r.reference)).toList();
        emit(current.copyWith(
          reservations:
              fresh.isEmpty ? null : [...current.reservations, ...fresh],
          isLoadingMore: false,
          hasReachedEnd: fresh.isEmpty,
          currentPage: fresh.isEmpty ? null : nextPage,
        ));
      } catch (e) {
        deboger(['[ReservationBloc] LoadMore échoué (liste conservée):', e]);
        emit(current.copyWith(isLoadingMore: false));
      }
    });

    on<RefreshReservations>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      try {
        final reservations = await reservationService.getUserReservations();
        emit(ReservationLoaded(reservations, currentReq: currentReq));
      } on CustomException catch (e) {
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de rafraîchissement", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<CancelReservation>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        await reservationService.cancelReservation(event.reference, motif: event.motif);
        emit(ReservationCancelled(event.reference, currentReq: currentReq, reservations: currentReservations));
        // Recharger la liste des réservations après annulation
        add(LoadUserReservations());
      } on CustomException catch (e) {
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur d'annulation", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue lors de l'annulation", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<ConfirmReservation>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        await reservationService.confirmReservation(event.reference);
        emit(ReservationConfirmed(event.reference, currentReq: currentReq, reservations: currentReservations));
        // Recharger la liste des réservations propriétaire après confirmation
        add(LoadProprietaireReservations());
      } on CustomException catch (e) {
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de confirmation", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue lors de la confirmation", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<RefuseReservation>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        await reservationService.refuseReservation(event.reference, motif: event.motif);
        emit(ReservationRefused(event.reference, currentReq: currentReq, reservations: currentReservations));
        // Recharger la liste des réservations propriétaire après refus
        add(LoadProprietaireReservations());
      } on CustomException catch (e) {
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de refus", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue lors du refus", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<PayReservation>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        await reservationService.payReservation(event.reference);
        emit(ReservationPaid(event.reference, currentReq: currentReq, reservations: currentReservations));
        // Recharger la liste des réservations client après paiement
        add(LoadUserReservations());
      } on CustomException catch (e) {
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de paiement", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue lors du paiement", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<LoadReservationCode>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        final code = await reservationService.getReservationCode(event.reference);
        emit(ReservationCodeLoaded(code, currentReq: currentReq, reservations: currentReservations));
      } on CustomException catch (e) {
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de chargement du code", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue lors du chargement du code", currentReq: currentReq, reservations: currentReservations));
      }
    });

    on<FinalizeReservation>((event, emit) async {
      final currentReq = state.currentReq;
      final currentReservations = state.reservations;
      emit(ReservationLoading(currentReq: currentReq, reservations: currentReservations));
      try {
        await reservationService.finalizeReservation(event.secretKey);
        emit(ReservationFinalized(event.secretKey, currentReq: currentReq, reservations: currentReservations));
        // Recharger la liste des réservations propriétaire après finalisation
        add(LoadProprietaireReservations());
      } on CustomException catch (e) {
        emit(ReservationError(e.message, currentReq: currentReq, reservations: currentReservations));
      } on DioException catch (e) {
        emit(ReservationError(e.response?.data.toString() ?? "Erreur de finalisation", currentReq: currentReq, reservations: currentReservations));
      } catch (e) {
        emit(ReservationError("Une erreur est survenue lors de la finalisation", currentReq: currentReq, reservations: currentReservations));
      }
    });

    // ==================== MISE À JOUR DEPUIS API ====================

    /// Met à jour l'état avec les données fraîches de l'API (background refresh)
    on<UpdateReservationsFromApi>((event, emit) {
      final currentReq = state.currentReq;
      deboger(['[ReservationBloc] Mise à jour avec données API: ${event.reservations.length} réservations']);
      emit(ReservationLoaded(event.reservations, currentReq: currentReq));
    });

    // ==================== RÉINITIALISATION ====================

    on<ClearAllReservations>((event, emit) {
      deboger('ClearAllReservations - Réinitialisation des réservations');
      emit(ReservationInitial());
    });

    on<ResetReservationState>((event, emit) {
      deboger(['[ReservationBloc] Réinitialisation à l\'état Initial']);
      emit(ReservationInitial());
    });
  }
}