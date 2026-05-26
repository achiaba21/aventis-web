import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/service/commodite/commodite_service.dart';

/// État du `CommoditeCubit` — liste du référentiel + flags chargement/erreur.
class CommoditeState {
  /// Référentiel chargé (vide tant que pas chargé).
  final List<Commodite> commodites;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  const CommoditeState({
    this.commodites = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  CommoditeState copyWith({
    List<Commodite>? commodites,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommoditeState(
      commodites: commodites ?? this.commodites,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Cubit exposant le référentiel des commodités (16+ chips wizard).
///
/// Stratégie V1 :
/// - Chargé une fois au login via `PreloadCoordinator` ou à la demande
/// - Pas de cache Hive (la table change rarement et le payload est minuscule)
/// - Refresh manuel possible via `load(force: true)`
class CommoditeCubit extends Cubit<CommoditeState> {
  final CommoditeService _service;

  CommoditeCubit({CommoditeService? service})
      : _service = service ?? CommoditeService.instance,
        super(const CommoditeState());

  /// Charge le référentiel. Idempotent si déjà chargé (sauf `force: true`).
  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (state.hasLoaded && !force) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    final list = await _service.fetchAll();
    if (list.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        hasLoaded: true, // marquer chargé pour éviter retry infini
        errorMessage: 'Référentiel commodités indisponible',
      ));
      return;
    }
    emit(state.copyWith(
      commodites: list,
      isLoading: false,
      hasLoaded: true,
      clearError: true,
    ));
  }

  /// Trouve une commodité par sa `value` (clé stable).
  Commodite? findByValue(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final c in state.commodites) {
      if (c.value == value) return c;
    }
    return null;
  }
}
