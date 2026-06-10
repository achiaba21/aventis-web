import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/document_cubit/document_cubit.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/map_bloc/map_bloc.dart';
import 'package:asfar/bloc/map_bloc/map_event.dart';
import 'package:asfar/model/websocket/websocket_state.dart';
import 'package:asfar/service/websocket/websocket_service.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/function.dart';

class RealtimeActionHandler {
  static RealtimeActionHandler? _instance;
  static RealtimeActionHandler get instance {
    _instance ??= RealtimeActionHandler._internal();
    return _instance!;
  }

  RealtimeActionHandler._internal();

  final WebSocketService _webSocketService = WebSocketService.instance;
  StreamSubscription<RealtimeAction>? _actionSubscription;
  BuildContext? _currentContext;

  // Initialiser le handler avec le contexte de l'app
  void initialize(BuildContext context) {
    _currentContext = context;
    _startListening();
  }

  void _startListening() {
    _actionSubscription?.cancel();
    _actionSubscription = _webSocketService.actionStream.listen(
      _handleRealtimeAction,
      onError: (error) {
        deboger('❌ Erreur stream actions temps réel: $error');
      },
    );

    deboger('⚡ RealtimeActionHandler initialisé');
  }

  void _handleRealtimeAction(RealtimeAction action) {
    if (_currentContext == null) {
      deboger('⚠️ Contexte non disponible pour l\'action: ${action.type}');
      return;
    }

    // Canal ciblé `/user/queue/updates` : enveloppe entityType/action.
    if (action.isUserUpdate) {
      deboger(
          '⚡ Update ciblée: ${action.entityType}/${action.entityAction}');
      _handleUserUpdate(action);
      return;
    }

    deboger('⚡ Action temps réel reçue: ${action.type}');

    try {
      switch (action.type) {
        case RealtimeAction.refreshFavorites:
          _handleRefreshFavorites(action);
          break;

        case RealtimeAction.refreshAppartements:
          _handleRefreshAppartements(action);
          break;

        case RealtimeAction.refreshBookings:
          _handleRefreshBookings(action);
          break;

        case RealtimeAction.refreshMapAppartements:
          _handleRefreshMapAppartements(action);
          break;

        case RealtimeAction.updateAppartementPrice:
          _handleUpdateAppartementPrice(action);
          break;

        case RealtimeAction.updateAppartementAvailability:
          _handleUpdateAppartementAvailability(action);
          break;

        case RealtimeAction.newAppartementInArea:
          _handleNewAppartementInArea(action);
          break;

        case RealtimeAction.newMessage:
          _handleNewMessage(action);
          break;

        case RealtimeAction.conversationUpdated:
          _handleConversationUpdated(action);
          break;

        case RealtimeAction.bookingConfirmed:
          _handleBookingConfirmed(action);
          break;

        default:
          deboger('⚠️ Type d\'action non géré: ${action.type}');
      }
    } catch (e) {
      deboger('❌ Erreur traitement action ${action.type}: $e');
    }
  }

  /// Dispatch des updates ciblées (`/user/queue/updates`) vers le bon bloc.
  /// Chaque entité patche/recharge son état localement, sans casser le flux si
  /// un provider est absent du contexte courant.
  void _handleUserUpdate(RealtimeAction action) {
    final ctx = _currentContext;
    if (ctx == null) return;
    try {
      switch (action.entityType) {
        case 'APPARTEMENT': // { appartementId, ancienStatus, nouveauStatus, motif }
          final id = (action.payload['appartementId'] as num?)?.toInt();
          final nouveau = action.payload['nouveauStatus'] as String?;
          ctx.read<AppartementBloc>().add(AppartementStatusPushed(id, nouveau));
          break;
        case 'DOCUMENT': // { documentUuid, etat, motif } (KYC)
          ctx.read<DocumentCubit>().load();
          break;
        case 'PARTENARIAT': // { demandeId, statut, proprioId, demarcheurId }
          final bloc = ctx.read<PartenariatBloc>();
          if (action.entityAction == 'CREATED') {
            bloc.add(const LoadDemandesRecues());
          } else if (action.entityAction == 'STATUS_CHANGED') {
            bloc.add(const LoadDemandesEnvoyees());
          } else {
            bloc.add(const LoadDemandesRecues());
            bloc.add(const LoadDemandesEnvoyees());
          }
          break;
        case 'RESERVATION': // { id, reference, statut, appartementId, ... }
          ctx.read<ReservationBloc>().add(RefreshReservations());
          break;
        default:
          deboger('⚠️ entityType non géré: ${action.entityType}');
      }
    } catch (e) {
      deboger('❌ Erreur dispatch update ${action.entityType}: $e');
    }
  }

  void _handleRefreshFavorites(RealtimeAction action) {
    try {
      final favoriteBloc = _currentContext!.read<FavoriteBloc>();
      favoriteBloc.add(LoadFavorites());

      deboger('💖 Actualisation des favoris déclenchée');

      // Afficher un message optionnel
      final message = action.payload['message'] as String?;
      if (message != null) {
        _showSnackBar(message, icon: Icons.favorite);
      }

    } catch (e) {
      deboger('❌ Erreur actualisation favoris: $e');
    }
  }

  void _handleRefreshAppartements(RealtimeAction action) {
    try {
      final appartementBloc = _currentContext!.read<AppartementBloc>();
      appartementBloc.add(LoadAppartements());

      deboger('🏠 Actualisation des appartements déclenchée');

      // Vérifier si on doit appliquer des filtres spécifiques
      final filterData = action.payload['filter'];
      if (filterData != null) {
        // Appliquer les filtres si nécessaire
        // appartementBloc.add(LoadFilteredAppartements(filter));
      }

      final message = action.payload['message'] as String?;
      if (message != null) {
        _showSnackBar(message, icon: Icons.home);
      }

    } catch (e) {
      deboger('❌ Erreur actualisation appartements: $e');
    }
  }

  void _handleRefreshBookings(RealtimeAction action) {
    try {
      // final reservationBloc = _currentContext!.read<ReservationBloc>();
      // reservationBloc.add(LoadUserReservations()); // À adapter selon vos events ReservationBloc

      deboger('📅 Actualisation des réservations déclenchée');

      final message = action.payload['message'] as String?;
      if (message != null) {
        _showSnackBar(message, icon: Icons.event);
      }

    } catch (e) {
      deboger('❌ Erreur actualisation réservations: $e');
    }
  }

  void _handleRefreshMapAppartements(RealtimeAction action) {
    try {
      final mapBloc = _currentContext!.read<MapBloc>();
      mapBloc.add(const RefreshMapData());

      deboger('🗺️ Actualisation de la carte déclenchée');

      final message = action.payload['message'] as String?;
      if (message != null) {
        _showSnackBar(message, icon: Icons.map);
      }

    } catch (e) {
      deboger('❌ Erreur actualisation carte: $e');
    }
  }

  void _handleUpdateAppartementPrice(RealtimeAction action) {
    try {
      final appartementId = action.payload['appartementId'] as int?;
      final newPrice = action.payload['newPrice'] as double?;
      final oldPrice = action.payload['oldPrice'] as double?;

      if (appartementId == null || newPrice == null) {
        deboger('⚠️ Données manquantes pour mise à jour prix');
        return;
      }

      // Actualiser les données
      final appartementBloc = _currentContext!.read<AppartementBloc>();
      appartementBloc.add(LoadAppartements());

      // Actualiser les favoris si cet appartement en fait partie
      final favoriteBloc = _currentContext!.read<FavoriteBloc>();
      favoriteBloc.add(LoadFavorites());

      // Actualiser la carte
      final mapBloc = _currentContext!.read<MapBloc>();
      mapBloc.add(const RefreshMapData());

      deboger('💰 Prix mis à jour pour appartement $appartementId: $newPrice');

      // Message utilisateur
      final priceChangeText = oldPrice != null
          ? (newPrice > oldPrice ? 'augmenté' : 'réduit')
          : 'modifié';

      _showSnackBar(
        'Prix $priceChangeText pour un appartement',
        icon: Icons.monetization_on,
        backgroundColor: newPrice > (oldPrice ?? 0) ? AppColors.error : AppColors.success,
      );

    } catch (e) {
      deboger('❌ Erreur mise à jour prix: $e');
    }
  }

  void _handleUpdateAppartementAvailability(RealtimeAction action) {
    try {
      final appartementId = action.payload['appartementId'] as int?;
      final isAvailable = action.payload['isAvailable'] as bool?;

      if (appartementId == null || isAvailable == null) {
        deboger('⚠️ Données manquantes pour mise à jour disponibilité');
        return;
      }

      // Actualiser toutes les données
      final appartementBloc = _currentContext!.read<AppartementBloc>();
      appartementBloc.add(LoadAppartements());

      final favoriteBloc = _currentContext!.read<FavoriteBloc>();
      favoriteBloc.add(LoadFavorites());

      final mapBloc = _currentContext!.read<MapBloc>();
      mapBloc.add(const RefreshMapData());

      deboger('🏠 Disponibilité mise à jour pour appartement $appartementId: $isAvailable');

      final statusText = isAvailable ? 'disponible' : 'réservé';
      _showSnackBar(
        'Un appartement est maintenant $statusText',
        icon: isAvailable ? Icons.check_circle : Icons.block,
        backgroundColor: isAvailable ? AppColors.success : AppColors.warning,
      );

    } catch (e) {
      deboger('❌ Erreur mise à jour disponibilité: $e');
    }
  }

  void _handleNewAppartementInArea(RealtimeAction action) {
    try {
      final lat = action.payload['lat'] as double?;
      final lng = action.payload['lng'] as double?;
      final appartementCount = action.payload['count'] as int? ?? 1;

      // Actualiser les appartements
      final appartementBloc = _currentContext!.read<AppartementBloc>();
      appartementBloc.add(LoadAppartements());

      // Actualiser la carte si on a les coordonnées
      if (lat != null && lng != null) {
        final mapBloc = _currentContext!.read<MapBloc>();
        mapBloc.add(const RefreshMapData());
      }

      deboger('🆕 $appartementCount nouvel(s) appartement(s) dans la zone');

      final message = appartementCount == 1
          ? 'Nouvel appartement disponible dans votre zone'
          : '$appartementCount nouveaux appartements dans votre zone';

      _showSnackBar(
        message,
        icon: Icons.new_releases,
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 5),
      );

    } catch (e) {
      deboger('❌ Erreur nouveau appartement: $e');
    }
  }

  void _handleNewMessage(RealtimeAction action) {
    try {
      final conversationBloc = _currentContext!.read<ConversationBloc>();
      conversationBloc.add(MessageReceived(messageData: action.payload));

      deboger('💬 Nouveau message reçu');

      final senderName = action.payload['expediteur']?['nom'] ?? 'Quelqu\'un';
      final messagePreview = action.payload['contenu'] as String? ?? 'Nouveau message';
      final preview = messagePreview.length > 50
          ? '${messagePreview.substring(0, 50)}...'
          : messagePreview;

      _showSnackBar(
        '$senderName: $preview',
        icon: Icons.message,
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 4),
      );

    } catch (e) {
      deboger('❌ Erreur nouveau message: $e');
    }
  }

  void _handleConversationUpdated(RealtimeAction action) {
    try {
      final conversationBloc = _currentContext!.read<ConversationBloc>();
      conversationBloc.add(ConversationUpdated(conversationData: action.payload));

      deboger('🔄 Conversation mise à jour');

      final message = action.payload['message'] as String?;
      if (message != null) {
        _showSnackBar(message, icon: Icons.chat_bubble);
      }

    } catch (e) {
      deboger('❌ Erreur mise à jour conversation: $e');
    }
  }

  void _handleBookingConfirmed(RealtimeAction action) {
    try {
      final bookingId = action.payload['bookingId'] as int?;
      final apartmentName = action.payload['apartmentName'] as String?;

      // Actualiser les réservations
      final reservationBloc = _currentContext!.read<ReservationBloc>();
      // reservationBloc.add(LoadUserReservations()); // À adapter selon votre ReservationBloc

      // TODO: Créer automatiquement une conversation
      // Nécessite les IDs du propriétaire et locataire qui ne sont pas disponibles ici
      // L'utilisateur peut créer la conversation manuellement depuis l'écran de détails
      // if (bookingId != null) {
      //   final conversationBloc = _currentContext!.read<ConversationBloc>();
      //   conversationBloc.add(CreateConversationFromBooking(...));
      // }

      deboger('✅ Réservation confirmée');

      final message = apartmentName != null
          ? 'Réservation confirmée pour $apartmentName. Vous pouvez maintenant contacter le propriétaire.'
          : 'Réservation confirmée. Vous pouvez maintenant contacter le propriétaire.';

      _showSnackBar(
        message,
        icon: Icons.check_circle,
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 6),
      );

    } catch (e) {
      deboger('❌ Erreur confirmation réservation: $e');
    }
  }

  void _showSnackBar(
    String message, {
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (_currentContext == null) return;

    try {
      ScaffoldMessenger.of(_currentContext!).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: backgroundColor ?? AppColors.info,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      deboger('❌ Erreur affichage SnackBar: $e');
    }
  }

  // Méthodes pour envoyer des actions personnalisées
  void sendRefreshAction(String type, {Map<String, dynamic>? payload}) {
    final action = RealtimeAction(
      type: type,
      payload: payload ?? {},
    );

    // Envoyer via WebSocket si connecté
    if (_webSocketService.isConnected) {
      _webSocketService.sendMessage('/app/actions', action.toJson());
      deboger('📤 Action envoyée: $type');
    } else {
      deboger('⚠️ WebSocket non connecté - action non envoyée: $type');
    }
  }

  void sendUserLocationUpdate(double lat, double lng) {
    sendRefreshAction('USER_LOCATION_UPDATE', payload: {
      'lat': lat,
      'lng': lng,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendUserPreferencesUpdate(Map<String, dynamic> preferences) {
    sendRefreshAction('USER_PREFERENCES_UPDATE', payload: preferences);
  }

  // Gestion du cycle de vie
  void updateContext(BuildContext context) {
    _currentContext = context;
  }

  void pause() {
    _actionSubscription?.pause();
    deboger('⏸️ RealtimeActionHandler en pause');
  }

  void resume() {
    _actionSubscription?.resume();
    deboger('▶️ RealtimeActionHandler repris');
  }

  void dispose() {
    _actionSubscription?.cancel();
    _actionSubscription = null;
    _currentContext = null;
    deboger('🛑 RealtimeActionHandler fermé');
  }
}