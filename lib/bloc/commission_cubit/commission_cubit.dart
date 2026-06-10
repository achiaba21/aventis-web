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
  ///
  /// `tauxPercent` est alimenté par l'API puis, à défaut, par le dernier taux
  /// connu en cache (cf. `CommissionCubit.load`). La constante `0.08` ci-dessous
  /// n'est donc plus qu'un **ultime recours** : premier lancement hors-ligne,
  /// sans aucune valeur jamais récupérée sur l'appareil.
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
    // Repli : si l'appel échoue, on retombe sur le dernier taux connu en cache
    // plutôt que sur la constante codée en dur (qui dérive du taux admin réel).
    final cached = _service.cachedTaux();
    final effective = taux ?? cached;
    emit(state.copyWith(
      tauxPercent: effective,
      isLoading: false,
      hasLoaded: true,
      errorMessage: taux == null
          ? (cached != null
              ? 'Taux hors-ligne (dernière valeur connue)'
              : 'Commission indisponible (valeur par défaut)')
          : null,
      clearError: taux != null,
    ));
  }
}
