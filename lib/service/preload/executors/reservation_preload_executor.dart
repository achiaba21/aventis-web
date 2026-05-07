import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/service/preload/executors/preload_executor.dart';
import 'package:asfar/util/function.dart';

/// Executor pour précharger les réservations de l'utilisateur
///
/// Principe SOLID - Single Responsibility (S) :
/// Responsabilité unique : précharger les données des réservations selon le rôle
///
/// Principe SOLID - Interface Segregation (I) :
/// Charge les bonnes réservations selon le type d'utilisateur (Locataire ou Propriétaire)
class ReservationPreloadExecutor implements PreloadExecutor {
  final ReservationBloc _reservationBloc;
  final User _user;

  ReservationPreloadExecutor({
    required ReservationBloc reservationBloc,
    required User user,
  })  : _reservationBloc = reservationBloc,
        _user = user;

  @override
  Future<void> execute() async {
    try {
      // Vérifier si les données sont déjà chargées
      final currentState = _reservationBloc.state;

      if (currentState is ReservationLoaded &&
          currentState.reservations.isNotEmpty) {
        deboger(['[ReservationPreloadExecutor] Données déjà chargées, skip preload']);
        return;
      }

      // Déterminer le type d'utilisateur pour charger les bonnes réservations
      final isProprietaire = _user is Proprietaire;
      final userRole = isProprietaire ? 'Propriétaire' : 'Locataire';

      deboger(['[ReservationPreloadExecutor] Démarrage du préchargement pour $userRole']);

      // ✅ Charger les réservations selon le rôle
      if (isProprietaire) {
        // Propriétaire : Réservations reçues sur ses propriétés
        _reservationBloc.add(LoadProprietaireReservations());
      } else {
        // Locataire : Réservations effectuées par l'utilisateur
        _reservationBloc.add(LoadUserReservations());
      }

      // Attendre la fin du chargement avec timeout
      await _reservationBloc.stream
          .firstWhere(
            (state) =>
                state is ReservationLoaded ||
                state is ReservationError,
            orElse: () => _reservationBloc.state,
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              deboger(['[ReservationPreloadExecutor] Timeout après 10 secondes']);
              return _reservationBloc.state;
            },
          );

      deboger(['[ReservationPreloadExecutor] Préchargement terminé pour $userRole']);
    } catch (e) {
      // Log l'erreur mais ne bloque pas le préchargement global
      deboger(['[ReservationPreloadExecutor] Erreur lors du préchargement: $e']);
    }
  }
}
