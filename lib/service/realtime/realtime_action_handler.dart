import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_event.dart';
import 'package:web_flutter/bloc/booking_bloc/booking_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_event.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_event.dart';
import 'package:web_flutter/bloc/map_bloc/map_bloc.dart';
import 'package:web_flutter/bloc/map_bloc/map_event.dart';
import 'package:web_flutter/model/websocket/websocket_state.dart';
import 'package:web_flutter/service/websocket/websocket_service.dart';
import 'package:web_flutter/util/function.dart';

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

        case RealtimeAction.refreshMapResidences:
          _handleRefreshMapResidences(action);
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
      // final bookingBloc = _currentContext!.read<BookingBloc>();
      // bookingBloc.add(LoadBookings()); // À adapter selon vos events BookingBloc

      deboger('📅 Actualisation des réservations déclenchée');

      final message = action.payload['message'] as String?;
      if (message != null) {
        _showSnackBar(message, icon: Icons.event);
      }

    } catch (e) {
      deboger('❌ Erreur actualisation réservations: $e');
    }
  }

  void _handleRefreshMapResidences(RealtimeAction action) {
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
        backgroundColor: newPrice > (oldPrice ?? 0) ? Colors.red : Colors.green,
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
        backgroundColor: isAvailable ? Colors.green : Colors.orange,
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
        backgroundColor: Colors.blue,
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
        backgroundColor: Colors.blue,
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
      final bookingBloc = _currentContext!.read<BookingBloc>();
      // bookingBloc.add(LoadBookings()); // À adapter selon votre BookingBloc

      // Créer automatiquement une conversation
      if (bookingId != null) {
        final conversationBloc = _currentContext!.read<ConversationBloc>();
        conversationBloc.add(CreateConversationFromBooking(bookingId: bookingId));
      }

      deboger('✅ Réservation confirmée - Conversation créée');

      final message = apartmentName != null
          ? 'Réservation confirmée pour $apartmentName. Vous pouvez maintenant contacter le propriétaire.'
          : 'Réservation confirmée. Vous pouvez maintenant contacter le propriétaire.';

      _showSnackBar(
        message,
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
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
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: backgroundColor ?? Colors.blue,
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