import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/model/filter/filter_criteria.dart';
import 'package:asfar/model/filter/filter_options.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/model/appartement/appartement_service.dart';
import 'package:asfar/util/custom_exception.dart';
import 'package:asfar/util/function.dart';

/// État du `AppartementFilterCubit`.
///
/// Pattern « keep last known data » : `criteria`, `options` et `filtered`
/// sont conservés à travers les transitions de `isLoading` / `errorMessage`.
class AppartementFilterState {
  /// Critères de filtre actuellement appliqués (null = pas de filtre actif).
  final FilterCriteria? criteria;

  /// Options de filtre disponibles (chargées via `loadOptions()`).
  final FilterOptions? options;

  /// Résultats du dernier filtre appliqué (vide si aucun filtre actif).
  final List<Appartement> filtered;

  final bool isLoading;
  final String? errorMessage;

  const AppartementFilterState({
    this.criteria,
    this.options,
    this.filtered = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory AppartementFilterState.initial() => const AppartementFilterState();

  bool get hasActiveCriteria => criteria != null;

  AppartementFilterState copyWith({
    FilterCriteria? criteria,
    bool clearCriteria = false,
    FilterOptions? options,
    List<Appartement>? filtered,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppartementFilterState(
      criteria: clearCriteria ? null : (criteria ?? this.criteria),
      options: options ?? this.options,
      filtered: filtered ?? this.filtered,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Cubit autonome gérant les filtres et résultats de recherche d'annonces.
///
/// Sorti du `AppartementBloc` pour découpler la logique de filtrage
/// (recherche locataire, démarcheur). Appelle directement le service —
/// les résultats filtrés ne sont pas cachés en Hive (chaque combinaison de
/// critères est différente).
class AppartementFilterCubit extends Cubit<AppartementFilterState> {
  final AppartementService _service = AppartementService();

  AppartementFilterCubit() : super(AppartementFilterState.initial());

  /// Charge les options de filtre depuis le backend (`auth/appartement/filter-options`).
  Future<void> loadOptions() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final options = await _service.getFilterOptions();
      emit(state.copyWith(options: options, isLoading: false));
    } catch (e) {
      _emitError(e);
    }
  }

  /// Applique un critère de filtre et fetch les résultats filtrés.
  Future<void> applyFilter(FilterCriteria criteria) async {
    emit(state.copyWith(
      criteria: criteria,
      isLoading: true,
      clearError: true,
    ));
    try {
      final results = await _service.getFilteredAppartements(criteria);
      emit(state.copyWith(filtered: results, isLoading: false));
    } catch (e) {
      _emitError(e);
    }
  }

  /// Réinitialise les filtres (garde les options pré-chargées).
  void clear() {
    emit(state.copyWith(
      clearCriteria: true,
      filtered: const [],
      clearError: true,
    ));
  }

  void _emitError(Object e) {
    String msg;
    if (e is CustomException) {
      msg = e.message;
    } else if (e is DioException) {
      msg = e.response?.data?.toString() ?? 'Erreur de filtrage';
    } else {
      msg = 'Une erreur est survenue';
    }
    deboger(['[AppartementFilterCubit] $msg', e]);
    emit(state.copyWith(isLoading: false, errorMessage: msg));
  }
}
