import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:asfar/service/firebase/fcm_background_handler.dart';
import 'package:asfar/bloc/active_shell_cubit/active_shell_cubit.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/commission_cubit/commission_cubit.dart';
import 'package:asfar/bloc/commodite_cubit/commodite_cubit.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/rule_cubit/rule_cubit.dart';
import 'package:asfar/bloc/availability_bloc/availability_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_bloc.dart';
import 'package:asfar/bloc/pays_bloc/pays_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/proprio_demarcheur_bloc/proprio_demarcheur_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/compte_bloc/compte_bloc.dart';
import 'package:asfar/bloc/compte_bloc/compte_event.dart';
import 'package:asfar/bloc/comptabilite_filter/comptabilite_filter_cubit.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/map_bloc/map_bloc.dart';
import 'package:asfar/bloc/map_bloc/map_event.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/service/migration/legacy_residence_migration.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/splash_screen.dart';
import 'package:asfar/theme/app_theme.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/service/connectivity/connectivity_service.dart';
import 'package:asfar/service/preload/preload_coordinator_builder.dart';
import 'package:asfar/util/json_constructors_registry.dart';
import 'package:asfar/util/function.dart';

/// Clé globale pour la navigation (utilisée pour la gestion de l'expiration du token)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Clé globale pour le ScaffoldMessenger (utilisée pour afficher les SnackBars depuis n'importe où)
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp();

  // Configurer le handler pour les messages FCM en arrière-plan
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialiser Hive pour le stockage local
  await Hive.initFlutter();

  // Initialiser StorageService (ouvrir les boxes)
  await StorageService.instance.init();

  // Migration one-shot : transfère l'address des anciennes résidences
  // dans les appartements et vide la box résidences. Idempotent.
  await LegacyResidenceMigration.instance.runIfNeeded();

  // Initialiser les locales pour intl (dates françaises)
  await initializeDateFormatting('fr_FR', null);

  // Enregistrer les constructeurs JSON pour DioRequest
  initializeJsonConstructors();

  // Résilience réseau : démarre la détection de connectivité (dérivée du
  // socket) dès le lancement, pour que l'intercepteur Dio puisse suspendre et
  // rejouer les requêtes échouées même avant la connexion du WebSocket.
  ConnectivityService.instance.start();

  // Activer le rendu edge-to-edge pour que le contenu s'affiche derrière la status bar
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // BlocProviders pour tous les blocs
        BlocProvider(create: (_) => UserBloc()),
        BlocProvider(create: (_) => ActiveShellCubit()),

        // AppartementBloc avec cache Hive (singleton AppartementRepository)
        BlocProvider(create: (_) => AppartementBloc()),
        BlocProvider(create: (_) => ReservationBloc()),
        BlocProvider(create: (_) => FavoriteBloc()),
        BlocProvider(create: (_) => ConversationBloc()),
        BlocProvider(create: (_) => NotificationBloc()),
        BlocProvider(create: (_) => MapBloc()),
        BlocProvider(create: (_) => ChargeBloc()),
        BlocProvider(create: (_) => CompteBloc()),
        BlocProvider(create: (_) => ComptabiliteFilterCubit()),
        BlocProvider(create: (_) => DemarcheurBloc()),
        BlocProvider(create: (_) => ProprietaireDemarcheurBloc()),
        BlocProvider(create: (_) => CalendarPlageBloc()),
        BlocProvider(create: (_) => AvailabilityBloc()),
        BlocProvider(create: (_) => PartenariatBloc()),
        BlocProvider(create: (_) => PaysBloc()),
        BlocProvider(create: (_) => CommoditeCubit()..load()),
        BlocProvider(create: (_) => RuleCubit()..load()),
        BlocProvider(create: (_) => CommissionCubit()..load()),
      ],
      child: const AppWithBlocListener(),
    );
  }
}

class AppWithBlocListener extends StatelessWidget {
  const AppWithBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // 1. Écouter UserBloc pour la déconnexion et le préchargement
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            // Quand l'utilisateur se déconnecte, réinitialiser toutes les données privées
            if (state is UserInitial) {
              _clearPrivateData(context);
            }

            // Quand l'utilisateur est connecté, déclencher le préchargement transparent
            if (state is UserLoaded) {
              // CRITIQUE: Définir l'utilisateur courant dans ConversationBloc
              // pour éviter l'erreur "Utilisateur non connecté" dans la messagerie
              context.read<ConversationBloc>().add(
                SetCurrentUser(user: state.loadedUser),
              );

              // P2 — Réactiver le temps réel après login. Connecte le WebSocket
              // (notifications + actions backend) et initialise FCM (push
              // notifs cloud). Sans ça, les messages et notifs n'arrivent
              // qu'au polling manuel.
              _initRealtime(context, state.loadedUser);

              // Attendre la fin de la navigation avant de démarrer le préchargement
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _startDataPreloading(context, state.loadedUser);
              });
            }
          },
        ),

      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Asfar',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const SplashScreen(),
      ),
    );
  }

  /// Réinitialise toutes les données privées lors de la déconnexion
  void _clearPrivateData(BuildContext context) {
    deboger(['[main.dart] Nettoyage des données privées...']);

    // ==================== DONNÉES LOCATAIRE ====================

    // Réservations
    context.read<ReservationBloc>().add(ClearAllReservations());

    // Favoris
    context.read<FavoriteBloc>().add(ClearAllFavorites());

    // Conversations
    context.read<ConversationBloc>().add(const ClearConversations());

    // Notifications (inclut la déconnexion WebSocket et FCM)
    context.read<NotificationBloc>().add(const DisconnectWebSocket());
    context.read<NotificationBloc>().add(const DeleteFCMToken());
    context.read<NotificationBloc>().add(const ResetNotificationState());

    // ==================== DONNÉES PROPRIÉTAIRE ====================

    // Appartements (proprio)
    context.read<AppartementBloc>().add(ResetAppartementState());

    // Charges
    context.read<ChargeBloc>().add(ResetChargeState());

    // Compte
    context.read<CompteBloc>().add(ResetCompteState());

    // ==================== DONNÉES PARTAGÉES ====================

    // Carte
    context.read<MapBloc>().add(const ResetMapState());

    // Partenariats
    context.read<PartenariatBloc>().add(const ResetPartenariatState());

    // ==================== VUE ACTIVE (V8.5) ====================

    // Reset la vue active persistée — au prochain login, on reprend la vue
    // par défaut du user.type.
    context.read<ActiveShellCubit>().clear();

    // ==================== CACHE HIVE ====================

    // Nettoyer le cache Hive (données propriétaire)
    StorageService.instance.clearProprioData();

    deboger(['[main.dart] Nettoyage des données privées terminé']);
  }

  /// P2 — Initialise la couche temps réel (WebSocket + FCM) après login.
  ///
  /// - `InitializeNotifications` connecte le WebSocket avec `userPhone` +
  ///   `authToken` et charge les notifications du cache + API.
  /// - `InitializeFCM` initialise Firebase Cloud Messaging et abonne le BLoC
  ///   aux streams notification/token pour les push notifs.
  ///
  /// Le cleanup (DisconnectWebSocket + DeleteFCMToken) est dispatché côté
  /// `_clearPrivateData` à la déconnexion.
  void _initRealtime(BuildContext context, User user) {
    final phone = user.telephone;
    if (phone == null || phone.isEmpty) {
      deboger('[main.dart] Pas de téléphone user → WebSocket non initialisé');
      return;
    }
    final token = StorageService.instance.getToken();
    context.read<NotificationBloc>().add(
          InitializeNotifications(
            userPhone: phone,
            authToken: token,
          ),
        );
    context.read<NotificationBloc>().add(const InitializeFCM());

    // Résilience réseau : démarre la détection de connectivité (dérivée du
    // socket). Idempotent. Le rejeu des requêtes échouées est géré au niveau
    // de l'intercepteur Dio (couvre tous les chargements de données).
    ConnectivityService.instance.start();
  }

  /// Démarre le préchargement transparent des données en arrière-plan
  ///
  /// Cette méthode est appelée après que l'utilisateur soit connecté
  /// et que la navigation vers le dashboard soit effectuée.
  ///
  /// Le préchargement est non-bloquant et s'exécute en arrière-plan
  /// pendant que l'utilisateur voit le dashboard.
  void _startDataPreloading(BuildContext context, User user) {
    // Ajouter un délai pour s'assurer que la navigation est complète
    // et que tous les widgets sont montés
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!context.mounted) return;

      deboger(['[main.dart] Démarrage du préchargement pour ${user.fullName}']);

      // Construire le coordinateur avec tous les executors nécessaires
      final coordinator = PreloadCoordinatorBuilder.build(context, user);

      // Lancer le préchargement en arrière-plan (fire-and-forget)
      // Les erreurs sont gérées en interne et ne bloquent pas l'application
      coordinator.startPreloading().catchError((error) {
        // Log l'erreur mais ne propage pas
        deboger(['[main.dart] Erreur globale de préchargement: $error']);
      });
    });
  }
}
