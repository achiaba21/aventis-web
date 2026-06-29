import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/config/service_locator.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/model/message/message.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/notification/notification_event.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/service/cache/conversation_cache_service.dart';
import 'package:asfar/service/model/message/message_service.dart';
import 'package:asfar/service/websocket/websocket_manager.dart';
import 'package:asfar/util/chat_message_merger.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/message_adapter.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessageService _messageService;
  final WebSocketManager _webSocketManager = WebSocketManager.instance;

  late final StreamSubscription _messageStreamSubscription;

  List<Conversation> _conversations = [];
  Map<int, List<ChatMessage>> _conversationMessages = {};
  User? _currentUser;

  ConversationBloc({MessageService? messageService})
      : _messageService = messageService ?? getIt<MessageService>(),
        super(const ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadConversationMessages>(_onLoadConversationMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkConversationAsRead>(_onMarkConversationAsRead);
    on<CreateConversationFromBooking>(_onCreateConversationFromBooking);
    on<MessageReceived>(_onMessageReceived);
    on<ConversationUpdated>(_onConversationUpdated);
    on<ClearConversations>(_onClearConversations);
    on<SetCurrentUser>(_onSetCurrentUser);
    on<ResetConversationState>(_onResetConversationState);
    on<LoadUnreadCount>(_onLoadUnreadCount);

    _initializeWebSocketListeners();
  }

  /// Plafonne la mémoire des messages (PERF-05) — mêmes limites que le cache
  /// disque [ConversationCacheService] :
  /// - au plus [ConversationCacheService.maxCachedMessages] messages conservés
  ///   par conversation (les plus récents) ;
  /// - au plus [ConversationCacheService.maxCachedConversations] conversations
  ///   en mémoire (éviction de la plus ancienne — elle se recharge depuis le
  ///   cache/API à la prochaine ouverture).
  void _capMessagesMemory(int conversationId) {
    final messages = _conversationMessages[conversationId];
    if (messages != null &&
        messages.length > ConversationCacheService.maxCachedMessages) {
      _conversationMessages[conversationId] = messages.sublist(
        messages.length - ConversationCacheService.maxCachedMessages,
      );
    }
    while (_conversationMessages.length >
        ConversationCacheService.maxCachedConversations) {
      final oldestKey = _conversationMessages.keys
          .firstWhere((k) => k != conversationId, orElse: () => conversationId);
      if (oldestKey == conversationId) break;
      _conversationMessages.remove(oldestKey);
    }
  }

  void _initializeWebSocketListeners() {
    _messageStreamSubscription = _webSocketManager.notificationStream.listen(
      (data) {
        try {
          // `notificationStream` émet des NotificationModel (pas des Map) :
          // l'ancien test `data is Map` était TOUJOURS faux → messages ignorés
          // → le thread ouvert ne se mettait jamais à jour en temps réel.
          if (data is! NotificationModel) return;
          if (data.event == NotificationEvent.message &&
              data.actionData != null) {
            add(MessageReceived(messageData: data.actionData!));
          }
        } catch (e) {
          deboger(['Erreur traitement message WebSocket:', e]);
        }
      },
      onError: (error) {
        deboger(['Erreur stream WebSocket messages:', error]);
      },
    );
  }

  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      if (_conversations.isEmpty || event.forceRefresh) {
        emit(const ConversationLoading());
      }

      if (_currentUser?.id == null) {
        emit(const ConversationError(message: 'Utilisateur non connecté'));
        return;
      }

      final seances = await _messageService.getSeances();
      final conversations = MessageAdapter.seancesToConversations(
        seances,
        _currentUser!.id!,
      );

      _conversations = conversations;
      emit(ConversationLoaded(conversations: conversations));

      deboger(['✅ ${conversations.length} conversations chargées']);
    } catch (e) {
      deboger(['❌ Erreur chargement conversations:', e]);
      emit(
        const ConversationError(
          message: 'Erreur lors du chargement des conversations',
        ),
      );
    }
  }

  Future<void> _onLoadConversationMessages(
    LoadConversationMessages event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversationId = event.conversationId;
      deboger([
        '🏁 _onLoadConversationMessages appelé pour conversation $conversationId',
        'User: ${_currentUser?.id}',
      ]);

      if (!_conversationMessages.containsKey(conversationId) ||
          event.forceRefresh) {
        emit(
          MessagesLoading(
            conversationId: conversationId,
            conversations: _conversations,
          ),
        );
      } else {
        // Si les messages sont déjà chargés, on les affiche tout de suite
        emit(
          MessagesLoaded(
            conversationId: conversationId,
            messages: _conversationMessages[conversationId]!,
            hasMore: false,
            conversations: _conversations,
          ),
        );
      }

      if (_currentUser?.id == null) {
        // On ne retourne pas d'erreur ici si on a déjà affiché les messages en cache
        // On peut essayer de récupérer l'utilisateur ou juste logger
        deboger([
          '⚠️ Utilisateur non connecté lors du chargement des messages',
        ]);
        if (!_conversationMessages.containsKey(conversationId)) {
          emit(
            MessagesError(
              conversationId: conversationId,
              message: 'Utilisateur non connecté',
            ),
          );
        }
        return;
      }

      deboger([
        '🔄 Récupération des messages depuis le serveur pour conversation $conversationId',
      ]);
      final messages = await _messageService.getMessages(conversationId);
      deboger(['📥 Réponse serveur: ${messages.length} messages récupérés']);

      final chatMessages = MessageAdapter.messagesToChats(
        messages,
        _currentUser!.id!,
        conversationId,
      );

      if (event.page == null || event.page! <= 1) {
        _conversationMessages[conversationId] = chatMessages;
      } else {
        final existingMessages = _conversationMessages[conversationId] ?? [];
        _conversationMessages[conversationId] = [
          ...existingMessages,
          ...chatMessages,
        ];
      }
      _capMessagesMemory(conversationId);

      emit(
        MessagesLoaded(
          conversationId: conversationId,
          messages: _conversationMessages[conversationId]!,
          hasMore: false,
          conversations: _conversations,
        ),
      );

      deboger([
        '✅ ${chatMessages.length} messages chargés pour conversation $conversationId (Total: ${_conversationMessages[conversationId]?.length})',
      ]);
    } catch (e, stackTrace) {
      deboger(['❌ Erreur chargement messages:', e, stackTrace]);
      emit(
        MessagesError(
          conversationId: event.conversationId,
          message: 'Erreur lors du chargement des messages',
        ),
      );
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversationId = event.conversationId;
      final contenu = event.contenu.trim();

      if (contenu.isEmpty) return;

      final tempMessage = ChatMessage(
        tempId: DateTime.now().millisecondsSinceEpoch.toString(),
        expediteur: _currentUser,
        contenu: contenu,
        createdAt: DateTime.now(),
        conversationId: conversationId,
        isSending: true,
        isRead: true,
      );

      final currentMessages = _conversationMessages[conversationId] ?? [];
      _conversationMessages[conversationId] = [...currentMessages, tempMessage];
      _capMessagesMemory(conversationId);

      emit(
        MessagesLoaded(
          conversationId: conversationId,
          messages: _conversationMessages[conversationId]!,
          hasMore: false,
          conversations: _conversations,
        ),
      );

      if (_currentUser?.id == null) {
        throw Exception('Utilisateur non connecté');
      }

      final sentMessageApi = await _messageService.sendMessage(
        seanceId: conversationId,
        contenu: contenu,
      );

      final sentMessage = MessageAdapter.messageToChat(
        sentMessageApi,
        _currentUser!.id!,
      );
      sentMessage.conversationId = conversationId;

      // Confirmation d'envoi : on remplace l'optimiste par son `tempId`. Le
      // merger supprime aussi tout écho temps réel du même message qui aurait
      // gagné la course contre la réponse HTTP (sinon → doublon).
      _conversationMessages[conversationId] = ChatMessageMerger.upsert(
        _conversationMessages[conversationId] ?? [],
        sentMessage,
        tempId: tempMessage.tempId,
      );

      emit(
        MessagesLoaded(
          conversationId: conversationId,
          messages: _conversationMessages[conversationId]!,
          hasMore: false,
          conversations: _conversations,
        ),
      );

      _updateConversationLastMessage(conversationId, sentMessage);

      // Émettre MessageSent pour que le widget SendMessage arrête le loader
      emit(MessageSent(conversationId: conversationId, message: sentMessage));

      deboger(['✅ Message envoyé avec succès']);
    } catch (e) {
      deboger(['❌ Erreur envoi message:', e]);

      final conversationId = event.conversationId;
      final messages = _conversationMessages[conversationId] ?? [];
      final updatedMessages =
          messages.map((msg) {
            if (msg.isSending == true && msg.tempId != null) {
              return msg.copyWith(isSending: false, hasFailed: true);
            }
            return msg;
          }).toList();

      _conversationMessages[conversationId] = updatedMessages;

      emit(
        MessagesLoaded(
          conversationId: conversationId,
          messages: _conversationMessages[conversationId]!,
          hasMore: false,
          conversations: _conversations,
        ),
      );

      // Émettre MessageSendError pour que le widget SendMessage arrête le loader et affiche l'erreur
      emit(MessageSendError(
        conversationId: conversationId,
        message: 'Erreur lors de l\'envoi du message',
      ));

      deboger(['❌ Erreur envoi message (UI mise à jour avec statut échec)']);
    }
  }

  Future<void> _onMarkConversationAsRead(
    MarkConversationAsRead event,
    Emitter<ConversationState> emit,
  ) async {
    final conversationId = event.conversationId;

    // Mise à jour optimiste : on vide le badge non-lus localement (liste +
    // fil) AVANT l'aller-retour réseau, pour un retour visuel immédiat.
    _conversations = _conversations.map((conv) {
      if (conv.id != conversationId) return conv;
      return Conversation(
        id: conv.id,
        proprietaire: conv.proprietaire,
        locataire: conv.locataire,
        dateDebut: conv.dateDebut,
        dateFin: conv.dateFin,
        active: conv.active,
        bookingId: conv.bookingId,
        messages: conv.messages,
        lastUpdated: conv.lastUpdated,
        lastMessage: conv.lastMessage,
        unreadCount: 0,
      );
    }).toList();

    final messages = _conversationMessages[conversationId] ?? [];
    _conversationMessages[conversationId] =
        messages.map((msg) => msg.copyWith(isRead: true)).toList();

    // On émet ConversationLoaded (et non MessagesLoaded) : la liste rafraîchit
    // son badge, tandis que le fil ouvert l'ignore (cf. buildWhen) — évite tout
    // clignotement du fil pendant que LoadConversationMessages charge encore.
    emit(ConversationLoaded(conversations: _conversations));

    // Synchronisation backend (le badge est déjà vidé côté UI ; en cas
    // d'échec on logge seulement, sans rollback agressif).
    try {
      await _messageService.markAsRead(conversationId);
      deboger(['✅ Conversation $conversationId marquée comme lue']);
    } catch (e) {
      deboger(['❌ Erreur marquage lecture (badge vidé localement):', e]);
    }
  }

  Future<void> _onCreateConversationFromBooking(
    CreateConversationFromBooking event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      emit(const ConversationCreating());

      if (_currentUser?.id == null) {
        emit(
          const ConversationCreateError(message: 'Utilisateur non connecté'),
        );
        return;
      }

      final seance = await _messageService.createSeance(
        proprietaireId: event.proprietaireId,
        locataireId: event.locataireId,
        reservationReference: event.reservationReference,
      );

      final conversation = MessageAdapter.seanceToConversation(
        seance,
        _currentUser!.id!,
      );

      _conversations = [conversation, ..._conversations];

      emit(ConversationCreated(conversation: conversation));

      deboger([
        '✅ Conversation créée pour réservation ${event.reservationReference}',
      ]);
    } catch (e) {
      deboger(['❌ Erreur création conversation:', e]);
      emit(
        const ConversationCreateError(
          message: 'Erreur lors de la création de la conversation',
        ),
      );
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<ConversationState> emit,
  ) {
    try {
      final data = event.messageData;
      // Le payload temps réel est le MÊME DTO que GET /seances/{id}/messages
      // (champs plats clientId/clientNom/clientType + lu) augmenté de seanceId.
      // On le parse via le même chemin que le REST (Message + MessageAdapter)
      // pour une cohérence totale (expéditeur, état lu, alignement des bulles).
      // Le payload du topic `/topic/seance/{id}` ne porte pas toujours de
      // `seanceId` : l'écran fournit alors `event.conversationId` en secours.
      final seanceId =
          data['seanceId'] ?? data['conversationId'] ?? event.conversationId;
      final currentUserId = _currentUser?.id;
      if (seanceId is! int || currentUserId == null) {
        deboger(
            '🐛[DEMANDE-MSG] DROPPÉ — seanceId=$seanceId, user=$currentUserId');
        return;
      }
      final message = MessageAdapter.messageToChat(
        Message.fromJson(data),
        currentUserId,
      ).copyWith(conversationId: seanceId);

      final existing = _conversationMessages[seanceId] ?? [];
      // Déjà présent par id (livré par un autre canal) : on le détecte AVANT
      // l'upsert pour éviter une ré-émission (donc un scroll) inutile.
      final isDuplicate =
          message.id != null && existing.any((m) => m.id == message.id);

      // Convergence idempotente : réconcilie l'optimiste, dédup par id — un
      // même message livré via le topic ET la file perso n'apparaît qu'une fois.
      _conversationMessages[seanceId] =
          ChatMessageMerger.upsert(existing, message);
      _capMessagesMemory(seanceId);

      if (isDuplicate) {
        deboger('🐛[DEMANDE-MSG] message ${message.id} déjà présent, dédup');
        return;
      }

      _updateConversationLastMessage(seanceId, message);

      emit(
        MessagesLoaded(
          conversationId: seanceId,
          messages: _conversationMessages[seanceId]!,
          hasMore: false,
          conversations: _conversations,
        ),
      );
      deboger(
          '📩 Nouveau message temps réel rangé dans la conversation $seanceId');
    } catch (e) {
      deboger(['❌ Erreur traitement message reçu:', e]);
    }
  }

  void _onConversationUpdated(
    ConversationUpdated event,
    Emitter<ConversationState> emit,
  ) {
    try {
      final conversationData = event.conversationData;
      final updatedConversation = Conversation.fromJson(conversationData);

      final updatedConversations =
          _conversations.map((conv) {
            if (conv.id == updatedConversation.id) {
              return updatedConversation;
            }
            return conv;
          }).toList();

      _conversations = updatedConversations;

      emit(ConversationLoaded(conversations: _conversations));

      deboger(['📝 Conversation ${updatedConversation.id} mise à jour']);
    } catch (e) {
      deboger(['❌ Erreur mise à jour conversation:', e]);
    }
  }

  void _onClearConversations(
    ClearConversations event,
    Emitter<ConversationState> emit,
  ) {
    _conversations.clear();
    _conversationMessages.clear();
    emit(const ConversationInitial());
    deboger(['🗑️ Conversations vidées']);
  }

  void _onSetCurrentUser(
    SetCurrentUser event,
    Emitter<ConversationState> emit,
  ) {
    _currentUser = event.user;
    // SEC-04 : pas de nom d'utilisateur dans les logs
    deboger(['👤 Utilisateur courant défini (#${_currentUser?.id})']);
  }

  void _updateConversationLastMessage(int conversationId, ChatMessage message) {
    final updatedConversations =
        _conversations.map((conv) {
          if (conv.id == conversationId) {
            return Conversation(
              id: conv.id,
              proprietaire: conv.proprietaire,
              locataire: conv.locataire,
              dateDebut: conv.dateDebut,
              dateFin: conv.dateFin,
              active: conv.active,
              bookingId: conv.bookingId,
              messages: conv.messages,
              lastUpdated: DateTime.now(),
              lastMessage: message,
              unreadCount: conv.unreadCount,
            );
          }
          return conv;
        }).toList();

    _conversations = updatedConversations;
  }

  /// Réinitialise le BLoC à son état Initial
  void _onResetConversationState(
    ResetConversationState event,
    Emitter<ConversationState> emit,
  ) {
    deboger(['[ConversationBloc] Réinitialisation à l\'état Initial']);
    _conversations = [];
    _conversationMessages = {};
    emit(const ConversationInitial());
  }

  /// Charger le nombre de messages non lus
  Future<void> _onLoadUnreadCount(
    LoadUnreadCount event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final count = await _messageService.getUnreadCount();
      emit(UnreadCountLoaded(count: count));
      deboger(['📬 Messages non lus: $count']);
    } catch (e) {
      deboger(['❌ Erreur chargement unread count:', e]);
    }
  }

  @override
  Future<void> close() {
    _messageStreamSubscription.cancel();
    return super.close();
  }
}
