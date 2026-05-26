import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/service/config/commission_service.dart';

/// État du `CommissionCubit` — taux + flags.
class CommissionState {
  /// Taux Asfar en **pourcentage** (ex. `5.0` pour 5 %). `null` tant que pas chargé.
  final double? tauxPercent;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  const CommissionState({
    this.tauxPercent,
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  /// Taux en **fraction** (ex. `0.05` pour 5 %), utile pour les calculs.
  /// Fallback `0.08` si non chargé (compat valeur historique).
  double get tauxFraction {
    if (tauxPercent == null) return 0.08;
    return tauxPercent! / 100;
  }

  CommissionState copyWith({
    double? tauxPercent,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CommissionState(
      tauxPercent: tauxPercent ?? this.tauxPercent,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Cubit exposant le taux de commission Asfar.
///
/// Chargement :
/// - Une fois au boot (via provider global dans main.dart)
/// - Refresh à chaque ouverture du step 5 wizard (cf. brief)
class CommissionCubit extends Cubit<CommissionState> {
  final CommissionService _service;

  CommissionCubit({CommissionService? service})
      : _service = service ?? CommissionService.instance,
        super(const CommissionState());

  /// Charge le taux. Idempotent si déjà chargé (sauf `force: true`).
  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (state.hasLoaded && !force) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    final taux = await _service.fetchTaux();
    emit(state.copyWith(
      tauxPercent: taux,
      isLoading: false,
      hasLoaded: true,
      errorMessage: taux == null ? 'Commission indisponible (fallback 8 %)' : null,
      clearError: taux != null,
    ));
  }
}
