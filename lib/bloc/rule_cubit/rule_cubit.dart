import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/model/residence/rule.dart';
import 'package:asfar/service/rule/rule_service.dart';

/// État du `RuleCubit` — liste du référentiel + flags chargement/erreur.
class RuleState {
  final List<Rule> rules;
  final bool isLoading;
  final bool hasLoaded;
  final String? errorMessage;

  const RuleState({
    this.rules = const [],
    this.isLoading = false,
    this.hasLoaded = false,
    this.errorMessage,
  });

  RuleState copyWith({
    List<Rule>? rules,
    bool? isLoading,
    bool? hasLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RuleState(
      rules: rules ?? this.rules,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Cubit exposant le référentiel des règles de maison.
///
/// Chargé au boot (provider global dans `main.dart`). Le wizard step 5
/// consomme directement le state pour afficher les toggles dynamiques.
class RuleCubit extends Cubit<RuleState> {
  final RuleService _service;

  RuleCubit({RuleService? service})
      : _service = service ?? RuleService.instance,
        super(const RuleState());

  /// Charge le référentiel. Idempotent si déjà chargé (sauf `force: true`).
  Future<void> load({bool force = false}) async {
    if (state.isLoading) return;
    if (state.hasLoaded && !force) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    final list = await _service.fetchAll();
    if (list.isEmpty) {
      emit(state.copyWith(
        isLoading: false,
        hasLoaded: true,
        errorMessage: 'Référentiel rules indisponible',
      ));
      return;
    }
    emit(state.copyWith(
      rules: list,
      isLoading: false,
      hasLoaded: true,
      clearError: true,
    ));
  }
}
