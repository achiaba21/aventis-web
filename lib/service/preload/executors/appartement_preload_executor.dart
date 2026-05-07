import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/service/preload/executors/preload_executor.dart';
import 'package:asfar/util/function.dart';

/// Executor pour précharger les appartements
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : précharger les données des appartements
class AppartementPreloadExecutor implements PreloadExecutor {
  final AppartementBloc _appartementBloc;
  final bool _isProprietaire;

  AppartementPreloadExecutor({
    required AppartementBloc appartementBloc,
    required bool isProprietaire,
  })  : _appartementBloc = appartementBloc,
        _isProprietaire = isProprietaire;

  @override
  Future<void> execute() async {
    try {
      // Vérifier si les données sont déjà chargées
      final currentState = _appartementBloc.state;

      final hasValidData = _checkIfDataAlreadyLoaded(currentState);

      if (hasValidData) {
        deboger(['[AppartementPreloadExecutor] Données déjà chargées, skip preload']);
        return;
      }

      deboger(['[AppartementPreloadExecutor] Démarrage du préchargement (isProprietaire: $_isProprietaire)']);

      // Charger selon le type d'utilisateur
      if (_isProprietaire) {
        _appartementBloc.add(LoadProprietaireAppartements());
      } else {
        _appartementBloc.add(LoadAppartements());
      }

      // Attendre la fin du chargement avec timeout
      await _appartementBloc.stream
          .firstWhere(
            (state) => _isLoadingComplete(state),
            orElse: () => _appartementBloc.state,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              deboger(['[AppartementPreloadExecutor] Timeout après 10 secondes']);
              return _appartementBloc.state;
            },
          );

      deboger(['[AppartementPreloadExecutor] Préchargement terminé']);
    } catch (e) {
      // Log l'erreur mais ne bloque pas le préchargement global
      deboger(['[AppartementPreloadExecutor] Erreur lors du préchargement: $e']);
    }
  }

  /// Vérifie si les données sont déjà chargées
  bool _checkIfDataAlreadyLoaded(AppartementState state) {
    if (_isProprietaire) {
      return state is ProprietaireAppartementsLoaded &&
          state.appartements.isNotEmpty;
    } else {
      return (state is AppartementLoaded && state.appartements.isNotEmpty) ||
          (state is FilteredAppartementsLoaded &&
              state.appartements.isNotEmpty);
    }
  }

  /// Vérifie si le chargement est terminé (succès ou erreur)
  bool _isLoadingComplete(AppartementState state) {
    if (_isProprietaire) {
      return state is ProprietaireAppartementsLoaded ||
          state is AppartementError;
    } else {
      return state is AppartementLoaded ||
          state is FilteredAppartementsLoaded ||
          state is AppartementError;
    }
  }
}
