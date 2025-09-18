import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_event.dart';
import 'package:web_flutter/bloc/conversation_bloc/conversation_state.dart';
import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/model/conversation/chat_message.dart';
import 'package:web_flutter/model/user/user.dart';
import 'package:web_flutter/service/model/conversation/conversation_service.dart';
import 'package:web_flutter/service/websocket/websocket_manager.dart';
import 'package:web_flutter/util/function.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationService _conversationService = ConversationService.instance;
  final WebSocketManager _webSocketManager = WebSocketManager.instance;

  late final StreamSubscription _messageStreamSubscription;

  List<Conversation> _conversations = [];
  Map<int, List<ChatMessage>> _conversationMessages = {};
  User? _currentUser;

  ConversationBloc() : super(const ConversationInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadConversationMessages>(_onLoadConversationMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessageAsRead>(_onMarkMessageAsRead);
    on<CreateConversationFromBooking>(_onCreateConversationFromBooking);
    on<MessageReceived>(_onMessageReceived);
    on<ConversationUpdated>(_onConversationUpdated);
    on<ClearConversations>(_onClearConversations);
    on<SetCurrentUser>(_onSetCurrentUser);

    _initializeWebSocketListeners();
  }

  void _initializeWebSocketListeners() {
    _messageStreamSubscription = _webSocketManager.notificationStream.listen(
      (data) {
        try {
          if (data is Map<String, dynamic>) {
            if (data['type'] == 'NEW_MESSAGE' || data['event'] == 'NEW_MESSAGE') {
              final payload = data['payload'] ?? data;
              if (payload is Map<String, dynamic>) {
                add(MessageReceived(messageData: payload));
              }
            } else if (data['type'] == 'CONVERSATION_UPDATE') {
              final payload = data['payload'] ?? data;
              if (payload is Map<String, dynamic>) {
                add(ConversationUpdated(conversationData: payload));
              }
            }
          }
        } catch (e) {
          deboger('L Erreur traitement message WebSocket: \$e');
        }
      },
      onError: (error) {
        deboger('L Erreur stream WebSocket messages: \$error');
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

      final conversations = await _conversationService.getUserConversations(
        forceRefresh: event.forceRefresh,
      );

      _conversations = conversations;
      emit(ConversationLoaded(conversations: conversations));

      deboger(' \${conversations.length} conversations charg�es');
    } catch (e) {
      deboger('L Erreur chargement conversations: \$e');
      emit(const ConversationError(message: 'Erreur lors du chargement des conversations'));
    }
  }

  Future<void> _onLoadConversationMessages(
    LoadConversationMessages event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversationId = event.conversationId;

      if (!_conversationMessages.containsKey(conversationId) || event.forceRefresh) {
        emit(MessagesLoading(conversationId: conversationId));
      }

      final messages = await _conversationService.getConversationMessages(
        conversationId,
        page: event.page,
        limit: event.limit,
        forceRefresh: event.forceRefresh,
      );

      if (event.page == null || event.page! <= 1) {
        _conversationMessages[conversationId] = messages;
      } else {
        final existingMessages = _conversationMessages[conversationId] ?? [];
        _conversationMessages[conversationId] = [...existingMessages, ...messages];
      }

      emit(MessagesLoaded(
        conversationId: conversationId,
        messages: _conversationMessages[conversationId]!,
        hasMore: messages.length >= (event.limit ?? 50),
      ));

      deboger(' \${messages.length} messages charg�s pour conversation \$conversationId');
    } catch (e) {
      deboger('L Erreur chargement messages: \$e');
      emit(MessagesError(
        conversationId: event.conversationId,
        message: 'Erreur lors du chargement des messages',
      ));
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

      emit(MessageSending(
        conversationId: conversationId,
        tempMessage: tempMessage,
      ));

      final sentMessage = await _conversationService.sendMessage(conversationId, contenu);

      final messages = _conversationMessages[conversationId] ?? [];
      final updatedMessages = messages.map((msg) {
        if (msg.tempId == tempMessage.tempId) {
          return sentMessage;
        }
        return msg;
      }).toList();

      _conversationMessages[conversationId] = updatedMessages;

      emit(MessageSent(
        conversationId: conversationId,
        message: sentMessage,
      ));

      _updateConversationLastMessage(conversationId, sentMessage);

      deboger(' Message envoy� avec succ�s');
    } catch (e) {
      deboger('L Erreur envoi message: \$e');

      final conversationId = event.conversationId;
      final messages = _conversationMessages[conversationId] ?? [];
      final updatedMessages = messages.map((msg) {
        if (msg.isSending == true && msg.tempId != null) {
          return msg.copyWith(isSending: false, hasFailed: true);
        }
        return msg;
      }).toList();

      _conversationMessages[conversationId] = updatedMessages;

      emit(MessageSendError(
        conversationId: conversationId,
        message: 'Erreur lors de l\'envoi du message',
      ));
    }
  }

  Future<void> _onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _conversationService.markMessageAsRead(
        event.conversationId,
        event.messageId,
      );

      final messages = _conversationMessages[event.conversationId] ?? [];
      final updatedMessages = messages.map((msg) {
        if (msg.id == event.messageId) {
          return msg.copyWith(isRead: true);
        }
        return msg;
      }).toList();

      _conversationMessages[event.conversationId] = updatedMessages;

      deboger(' Message marqu� comme lu');
    } catch (e) {
      deboger('L Erreur marquage lecture: \$e');
    }
  }

  Future<void> _onCreateConversationFromBooking(
    CreateConversationFromBooking event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      emit(ConversationCreating(bookingId: event.bookingId));

      final conversation = await _conversationService.createConversationFromBooking(
        event.bookingId,
      );

      _conversations = [conversation, ..._conversations];

      emit(ConversationCreated(conversation: conversation));

      deboger(' Conversation cr��e pour booking \${event.bookingId}');
    } catch (e) {
      deboger('L Erreur cr�ation conversation: \$e');
      emit(ConversationCreateError(
        bookingId: event.bookingId,
        message: 'Erreur lors de la cr�ation de la conversation',
      ));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<ConversationState> emit,
  ) {
    try {
      final messageData = event.messageData;
      final message = ChatMessage.fromJson(messageData);

      if (message.conversationId != null) {
        final currentMessages = _conversationMessages[message.conversationId!] ?? [];
        _conversationMessages[message.conversationId!] = [...currentMessages, message];

        _updateConversationLastMessage(message.conversationId!, message);

        emit(NewMessageReceived(message: message));

        deboger('=� Nouveau message re�u pour conversation \${message.conversationId}');
      }
    } catch (e) {
      deboger('L Erreur traitement message re�u: \$e');
    }
  }

  void _onConversationUpdated(
    ConversationUpdated event,
    Emitter<ConversationState> emit,
  ) {
    try {
      final conversationData = event.conversationData;
      final updatedConversation = Conversation.fromJson(conversationData);

      final updatedConversations = _conversations.map((conv) {
        if (conv.id == updatedConversation.id) {
          return updatedConversation;
        }
        return conv;
      }).toList();

      _conversations = updatedConversations;

      emit(ConversationLoaded(conversations: _conversations));

      deboger('= Conversation \${updatedConversation.id} mise � jour');
    } catch (e) {
      deboger('L Erreur mise � jour conversation: \$e');
    }
  }

  void _onClearConversations(
    ClearConversations event,
    Emitter<ConversationState> emit,
  ) {
    _conversations.clear();
    _conversationMessages.clear();
    _conversationService.clearCache();
    emit(const ConversationInitial());
    deboger('>� Conversations vid�es');
  }

  void _onSetCurrentUser(
    SetCurrentUser event,
    Emitter<ConversationState> emit,
  ) {
    _currentUser = event.user;
    _conversationService.setCurrentUser(_currentUser);
    deboger('=d Utilisateur courant défini: ${_currentUser?.fullName}');
  }

  void _updateConversationLastMessage(int conversationId, ChatMessage message) {
    final updatedConversations = _conversations.map((conv) {
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

  @override
  Future<void> close() {
    _messageStreamSubscription.cancel();
    return super.close();
  }
}