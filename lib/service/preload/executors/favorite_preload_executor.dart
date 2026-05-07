import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/service/preload/executors/preload_executor.dart';
import 'package:asfar/util/function.dart';

/// Executor pour précharger les favoris de l'utilisateur
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : précharger les données des favoris
class FavoritePreloadExecutor implements PreloadExecutor {
  final FavoriteBloc _favoriteBloc;

  FavoritePreloadExecutor({
    required FavoriteBloc favoriteBloc,
  }) : _favoriteBloc = favoriteBloc;

  @override
  Future<void> execute() async {
    try {
      // Vérifier si les données sont déjà chargées
      final currentState = _favoriteBloc.state;

      // FavoriteBloc utilise un cache-first pattern
      // Les données peuvent déjà être chargées depuis SharedPreferences
      if (currentState is FavoriteLoaded) {
        deboger(['[FavoritePreloadExecutor] Données déjà chargées, skip preload']);
        return;
      }

      // Si état d'erreur ou initial, tenter le chargement
      if (currentState is FavoriteInitial || currentState is FavoriteError) {
        deboger(['[FavoritePreloadExecutor] Démarrage du préchargement']);

        // Déclencher le chargement (cache-first + API)
        _favoriteBloc.add(LoadFavorites());

        // Attendre la fin du chargement avec timeout
        await _favoriteBloc.stream
            .firstWhere(
              (state) =>
                  state is FavoriteLoaded ||
                  state is FavoriteActionSuccess ||
                  state is FavoriteError,
              orElse: () => _favoriteBloc.state,
            )
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                deboger(['[FavoritePreloadExecutor] Timeout après 10 secondes']);
                return _favoriteBloc.state;
              },
            );

        deboger(['[FavoritePreloadExecutor] Préchargement terminé']);
      }
    } catch (e) {
      // Log l'erreur mais ne bloque pas le préchargement global
      deboger(['[FavoritePreloadExecutor] Erreur lors du préchargement: $e']);
    }
  }
}
