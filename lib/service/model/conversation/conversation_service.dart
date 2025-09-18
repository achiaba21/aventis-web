import 'package:dio/dio.dart';
import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/model/conversation/chat_message.dart';
import 'package:web_flutter/model/user/user.dart';
import 'package:web_flutter/service/cache/conversation_cache_service.dart';
import 'package:web_flutter/service/dio/dio_request.dart';
import 'package:web_flutter/util/function.dart';

class ConversationService {
  static ConversationService? _instance;
  static ConversationService get instance {
    _instance ??= ConversationService._internal();
    return _instance!;
  }

  ConversationService._internal();

  final ConversationCacheService _cacheService = ConversationCacheService.instance;
  final DioRequest _dioRequest = DioRequest.instance;

  User? _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }

  // === CONVERSATIONS ===

  Future<List<Conversation>> getUserConversations({bool forceRefresh = false}) async {
    try {
      // 1. Charger depuis le cache d'abord (si pas de refresh forcé)
      if (!forceRefresh) {
        final cachedConversations = await _cacheService.getCachedConversations();
        if (cachedConversations.isNotEmpty) {
          deboger('📱 Retour \${cachedConversations.length} conversations depuis le cache');

          // Charger en background pour mise à jour
          _loadConversationsFromNetwork().then((networkConversations) {
            if (networkConversations.isNotEmpty) {
              _cacheService.cacheConversations(networkConversations);
            }
          }).catchError((e) {
            deboger('❌ Erreur chargement background conversations: \$e');
          });

          return cachedConversations;
        }
      }

      // 2. Charger depuis le réseau
      return await _loadConversationsFromNetwork();

    } catch (e) {
      deboger('❌ Erreur getUserConversations: \$e');

      // Fallback sur cache en cas d'erreur réseau
      try {
        final cachedConversations = await _cacheService.getCachedConversations();
        if (cachedConversations.isNotEmpty) {
          deboger('🔄 Fallback sur cache après erreur réseau');
          return cachedConversations;
        }
      } catch (cacheError) {
        deboger('❌ Erreur fallback cache: \$cacheError');
      }

      rethrow;
    }
  }

  Future<List<Conversation>> _loadConversationsFromNetwork() async {
    try {
      final response = await _dioRequest.get('/conversations');

      if (response.statusCode == 200) {
        final List<dynamic> conversationsJson = response.data['data'] ?? response.data;
        final conversations = conversationsJson
            .map((json) => Conversation.fromJson(json))
            .toList();

        // Mettre en cache
        await _cacheService.cacheConversations(conversations);

        deboger('✅ \${conversations.length} conversations chargées depuis le réseau');
        return conversations;
      } else {
        throw Exception('Erreur chargement conversations: \${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur _loadConversationsFromNetwork: \$e');
      rethrow;
    }
  }

  Future<Conversation?> getConversation(int conversationId, {bool forceRefresh = false}) async {
    try {
      // 1. Charger depuis le cache d'abord
      if (!forceRefresh) {
        final cachedConversation = await _cacheService.getCachedConversation(conversationId);
        if (cachedConversation != null) {
          deboger('📱 Conversation \$conversationId trouvée en cache');
          return cachedConversation;
        }
      }

      // 2. Charger depuis le réseau
      final response = await _dioRequest.get('/conversations/\$conversationId');

      if (response.statusCode == 200) {
        final conversation = Conversation.fromJson(response.data['data'] ?? response.data);

        // Mettre en cache
        await _cacheService.cacheConversation(conversation);

        deboger('✅ Conversation \$conversationId chargée depuis le réseau');
        return conversation;
      } else {
        throw Exception('Erreur chargement conversation: \${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur getConversation: \$e');
      rethrow;
    }
  }

  Future<Conversation> createConversationFromBooking(int bookingId) async {
    try {
      final response = await _dioRequest.post(
        '/conversations/from-booking',
        data: {'bookingId': bookingId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final conversation = Conversation.fromJson(response.data['data'] ?? response.data);

        // Mettre en cache
        await _cacheService.cacheConversation(conversation);

        deboger('✅ Conversation créée pour booking \$bookingId');
        return conversation;
      } else {
        throw Exception('Erreur création conversation: \${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur createConversationFromBooking: \$e');
      rethrow;
    }
  }

  // === MESSAGES ===

  Future<List<ChatMessage>> getConversationMessages(
    int conversationId, {
    int? page,
    int? limit,
    bool forceRefresh = false,
  }) async {
    try {
      // 1. Charger depuis le cache d'abord
      if (!forceRefresh && (page == null || page <= 1)) {
        final cachedMessages = await _cacheService.getCachedMessages(conversationId);
        if (cachedMessages.isNotEmpty) {
          deboger('📱 \${cachedMessages.length} messages trouvés en cache pour conversation \$conversationId');

          // Charger les nouveaux messages en background
          _loadMessagesFromNetwork(conversationId, page: 1, limit: limit).then((networkMessages) {
            if (networkMessages.isNotEmpty) {
              _cacheService.cacheMessages(conversationId, networkMessages);
            }
          }).catchError((e) {
            deboger('❌ Erreur chargement background messages: \$e');
          });

          return cachedMessages;
        }
      }

      // 2. Charger depuis le réseau
      return await _loadMessagesFromNetwork(conversationId, page: page, limit: limit);

    } catch (e) {
      deboger('❌ Erreur getConversationMessages: \$e');

      // Fallback sur cache
      try {
        final cachedMessages = await _cacheService.getCachedMessages(conversationId);
        if (cachedMessages.isNotEmpty) {
          deboger('🔄 Fallback sur cache messages après erreur réseau');
          return cachedMessages;
        }
      } catch (cacheError) {
        deboger('❌ Erreur fallback cache messages: \$cacheError');
      }

      rethrow;
    }
  }

  Future<List<ChatMessage>> _loadMessagesFromNetwork(
    int conversationId, {
    int? page,
    int? limit,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (page != null) queryParameters['page'] = page;
      if (limit != null) queryParameters['limit'] = limit;

      final response = await _dioRequest.get(
        '/conversations/\$conversationId/messages',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = response.data['data'] ?? response.data;
        final messages = messagesJson
            .map((json) => ChatMessage.fromJson(json))
            .toList();

        // Mettre en cache seulement si c'est la première page
        if (page == null || page <= 1) {
          await _cacheService.cacheMessages(conversationId, messages);
        }

        deboger('✅ \${messages.length} messages chargés depuis le réseau pour conversation \$conversationId');
        return messages;
      } else {
        throw Exception('Erreur chargement messages: \${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur _loadMessagesFromNetwork: \$e');
      rethrow;
    }
  }

  Future<ChatMessage> sendMessage(int conversationId, String contenu) async {
    // 1. Créer message temporaire pour UI optimiste
    final tempMessage = ChatMessage(
      tempId: DateTime.now().millisecondsSinceEpoch.toString(),
      expediteur: _currentUser,
      contenu: contenu,
      createdAt: DateTime.now(),
      conversationId: conversationId,
      isSending: true,
      isRead: true, // Nos propres messages sont marqués comme lus
    );

    try {
      // 2. Envoyer au serveur
      final response = await _dioRequest.post(
        '/conversations/\$conversationId/messages',
        data: {
          'contenu': contenu,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final message = ChatMessage.fromJson(response.data['data'] ?? response.data);

        // 3. Mettre en cache le vrai message
        await _cacheService.cacheMessage(message);

        deboger('✅ Message envoyé avec succès');
        return message;
      } else {
        // Marquer le message temporaire comme échoué
        final failedMessage = tempMessage.copyWith(
          isSending: false,
          hasFailed: true,
        );
        throw Exception('Erreur envoi message: \${response.statusCode}');
      }
    } catch (e) {
      deboger('❌ Erreur sendMessage: \$e');

      // Retourner le message temporaire marqué comme échoué
      final failedMessage = tempMessage.copyWith(
        isSending: false,
        hasFailed: true,
      );

      rethrow;
    }
  }

  Future<void> markMessageAsRead(int conversationId, int messageId) async {
    try {
      // 1. Marquer en local immédiatement
      await _cacheService.markMessageAsRead(conversationId, messageId);

      // 2. Envoyer au serveur
      await _dioRequest.put('/conversations/\$conversationId/messages/\$messageId/read');

      deboger('✅ Message \$messageId marqué comme lu');
    } catch (e) {
      deboger('❌ Erreur markMessageAsRead: \$e');
      // Ne pas rethrow pour éviter d'impacter l'UX
    }
  }

  // === UTILITAIRES ===

  Future<void> clearCache() async {
    await _cacheService.clearCache();
  }

  Future<void> dispose() async {
    await _cacheService.dispose();
  }
}