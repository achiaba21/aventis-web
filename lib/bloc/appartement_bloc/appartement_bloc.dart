import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_event.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_state.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/service/model/appartement/appartement_service.dart';
import 'package:web_flutter/util/custom_exception.dart';
import 'package:web_flutter/util/function.dart';

class AppartementBloc extends Bloc<AppartementEvent, AppartementState> {
  late AppartementService appartementService;

  AppartementBloc() : super(AppartementInitial()) {
    appartementService = AppartementService();

    on<LoadAppartements>((event, emit) async {
      emit(AppartementLoading());
      try {
        final appartements = await appartementService.getAppartements();
        deboger(["appartements :", appartements]);
        emit(AppartementLoaded(appartements));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de r�cup�ration"));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue"));
        deboger(e);
      }
    });

    on<RefreshAppartements>((event, emit) async {
      try {
        final appartements = await appartementService.getAppartements();
        emit(AppartementLoaded(appartements));
      } on CustomException catch (e) {
        emit(AppartementError(e.message));
      } on DioException catch (e) {
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de r�cup�ration"));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue"));
        deboger(e);
      }
    });

    on<LoadAppartementsByOwner>((event, emit) async {
      emit(AppartementLoading());
      try {
        final appartements = await appartementService.getAppartementsByOwner(event.proprietaireId);
        deboger(["appartements by owner :", appartements]);
        emit(AppartementsByOwnerLoaded(appartements, event.proprietaireId));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de r�cup�ration"));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue"));
        deboger(e);
      }
    });

    on<LoadFilteredAppartements>((event, emit) async {
      emit(AppartementLoading());
      try {
        final appartements = await appartementService.getFilteredAppartements(event.criteria);
        deboger(["filtered appartements :", appartements]);
        emit(FilteredAppartementsLoaded(appartements, event.criteria));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération"));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue"));
        deboger(e);
      }
    });

    on<LoadFilterOptions>((event, emit) async {
      try {
        final options = await appartementService.getFilterOptions();
        deboger(["filter options :", options]);
        // Préserver les appartements actuels si disponibles
        List<Appartement>? currentAppartements;
        if (state is AppartementLoaded) {
          currentAppartements = (state as AppartementLoaded).appartements;
        } else if (state is FilteredAppartementsLoaded) {
          currentAppartements = (state as FilteredAppartementsLoaded).appartements;
        }
        emit(FilterOptionsLoaded(options, currentAppartements));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération"));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue"));
        deboger(e);
      }
    });

    on<ClearFilters>((event, emit) async {
      emit(AppartementLoading());
      try {
        final appartements = await appartementService.getAppartements();
        deboger(["clear filters - all appartements :", appartements]);
        emit(AppartementLoaded(appartements));
      } on CustomException catch (e) {
        deboger([e]);
        emit(AppartementError(e.message));
      } on DioException catch (e) {
        deboger(["dio :", e]);
        emit(AppartementError(e.response?.data.toString() ?? "Erreur de récupération"));
      } catch (e) {
        emit(AppartementError("Une erreur est survenue"));
        deboger(e);
      }
    });
  }
}