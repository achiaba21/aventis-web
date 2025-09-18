import 'package:hive_flutter/hive_flutter.dart';
import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/model/conversation/chat_message.dart';
import 'package:web_flutter/model/user/user.dart';
import 'package:web_flutter/util/function.dart';

class ConversationCacheService {
  static ConversationCacheService? _instance;
  static ConversationCacheService get instance {
    _instance ??= ConversationCacheService._internal();
    return _instance!;
  }

  ConversationCacheService._internal();

  Box<Conversation>? _conversationBox;
  Box<ChatMessage>? _messageBox;

  static const String _conversationBoxName = 'conversations';
  static const String _messageBoxName = 'messages';
  static const int _maxCachedMessages = 100; // Limite par conversation
  static const int _maxCachedConversations = 50;

  Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Enregistrer les adaptateurs si pas déjà fait
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ConversationAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(ChatMessageAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(UserAdapter());
      }

      _conversationBox = await Hive.openBox<Conversation>(_conversationBoxName);
      _messageBox = await Hive.openBox<ChatMessage>(_messageBoxName);

      deboger('✅ ConversationCacheService initialisé');
    } catch (e) {
      deboger('❌ Erreur initialisation ConversationCacheService: \$e');
      rethrow;
    }
  }

  // === CONVERSATIONS ===

  Future<List<Conversation>> getCachedConversations() async {
    if (_conversationBox == null) await initialize();

    try {
      final conversations = _conversationBox!.values.toList();
      conversations.sort((a, b) {
        final aTime = a.lastUpdated ?? DateTime(1970);
        final bTime = b.lastUpdated ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      deboger('📱 Récupération de \${conversations.length} conversations en cache');
      return conversations;
    } catch (e) {
      deboger('❌ Erreur récupération conversations cache: \$e');
      return [];
    }
  }

  Future<Conversation?> getCachedConversation(int conversationId) async {
    if (_conversationBox == null) await initialize();

    try {
      return _conversationBox!.get(conversationId);
    } catch (e) {
      deboger('❌ Erreur récupération conversation \$conversationId: \$e');
      return null;
    }
  }

  Future<void> cacheConversation(Conversation conversation) async {
    if (_conversationBox == null) await initialize();

    try {
      if (conversation.id != null) {
        conversation.lastUpdated = DateTime.now();
        await _conversationBox!.put(conversation.id!, conversation);

        // Nettoyer les anciennes conversations si limite dépassée
        await _cleanOldConversations();

        deboger('💾 Conversation \${conversation.id} mise en cache');
      }
    } catch (e) {
      deboger('❌ Erreur cache conversation: \$e');
    }
  }

  Future<void> cacheConversations(List<Conversation> conversations) async {
    if (_conversationBox == null) await initialize();

    try {
      final Map<int, Conversation> conversationMap = {};

      for (final conversation in conversations) {
        if (conversation.id != null) {
          conversation.lastUpdated = DateTime.now();
          conversationMap[conversation.id!] = conversation;
        }
      }

      await _conversationBox!.putAll(conversationMap);
      await _cleanOldConversations();

      deboger('💾 \${conversations.length} conversations mises en cache');
    } catch (e) {
      deboger('❌ Erreur cache conversations: \$e');
    }
  }

  // === MESSAGES ===

  Future<List<ChatMessage>> getCachedMessages(int conversationId) async {
    if (_messageBox == null) await initialize();

    try {
      final allMessages = _messageBox!.values
          .where((message) => message.conversationId == conversationId)
          .toList();

      allMessages.sort((a, b) {
        final aTime = a.createdAt ?? DateTime(1970);
        final bTime = b.createdAt ?? DateTime(1970);
        return aTime.compareTo(bTime);
      });

      deboger('💬 Récupération de \${allMessages.length} messages pour conversation \$conversationId');
      return allMessages;
    } catch (e) {
      deboger('❌ Erreur récupération messages cache: \$e');
      return [];
    }
  }

  Future<void> cacheMessage(ChatMessage message) async {
    if (_messageBox == null) await initialize();

    try {
      if (message.id != null) {
        await _messageBox!.put('\${message.conversationId}_\${message.id}', message);

        // Nettoyer les anciens messages si limite dépassée
        await _cleanOldMessages(message.conversationId!);

        deboger('💬 Message \${message.id} mis en cache');
      }
    } catch (e) {
      deboger('❌ Erreur cache message: \$e');
    }
  }

  Future<void> cacheMessages(int conversationId, List<ChatMessage> messages) async {
    if (_messageBox == null) await initialize();

    try {
      final Map<String, ChatMessage> messageMap = {};

      for (final message in messages) {
        if (message.id != null) {
          message.conversationId = conversationId;
          messageMap['\${conversationId}_\${message.id}'] = message;
        }
      }

      await _messageBox!.putAll(messageMap);
      await _cleanOldMessages(conversationId);

      deboger('💬 \${messages.length} messages mis en cache pour conversation \$conversationId');
    } catch (e) {
      deboger('❌ Erreur cache messages: \$e');
    }
  }

  // === NETTOYAGE ===

  Future<void> _cleanOldConversations() async {
    try {
      final conversations = _conversationBox!.values.toList();

      if (conversations.length > _maxCachedConversations) {
        conversations.sort((a, b) {
          final aTime = a.lastUpdated ?? DateTime(1970);
          final bTime = b.lastUpdated ?? DateTime(1970);
          return aTime.compareTo(bTime);
        });

        final toDelete = conversations.take(conversations.length - _maxCachedConversations);
        for (final conversation in toDelete) {
          if (conversation.id != null) {
            await _conversationBox!.delete(conversation.id!);
          }
        }

        deboger('🧹 Nettoyage: \${toDelete.length} anciennes conversations supprimées');
      }
    } catch (e) {
      deboger('❌ Erreur nettoyage conversations: \$e');
    }
  }

  Future<void> _cleanOldMessages(int conversationId) async {
    try {
      final messages = _messageBox!.values
          .where((message) => message.conversationId == conversationId)
          .toList();

      if (messages.length > _maxCachedMessages) {
        messages.sort((a, b) {
          final aTime = a.createdAt ?? DateTime(1970);
          final bTime = b.createdAt ?? DateTime(1970);
          return aTime.compareTo(bTime);
        });

        final toDelete = messages.take(messages.length - _maxCachedMessages);
        for (final message in toDelete) {
          if (message.id != null) {
            await _messageBox!.delete('\${conversationId}_\${message.id}');
          }
        }

        deboger('🧹 Nettoyage: \${toDelete.length} anciens messages supprimés pour conversation \$conversationId');
      }
    } catch (e) {
      deboger('❌ Erreur nettoyage messages: \$e');
    }
  }

  // === UTILITAIRES ===

  Future<void> markMessageAsRead(int conversationId, int messageId) async {
    try {
      final key = '\${conversationId}_\$messageId';
      final message = _messageBox!.get(key);

      if (message != null) {
        final updatedMessage = message.copyWith(isRead: true);
        await _messageBox!.put(key, updatedMessage);

        deboger('✅ Message \$messageId marqué comme lu');
      }
    } catch (e) {
      deboger('❌ Erreur marquage lecture: \$e');
    }
  }

  Future<void> clearCache() async {
    try {
      await _conversationBox?.clear();
      await _messageBox?.clear();
      deboger('🧹 Cache conversations vidé');
    } catch (e) {
      deboger('❌ Erreur vidage cache: \$e');
    }
  }

  Future<void> dispose() async {
    try {
      await _conversationBox?.close();
      await _messageBox?.close();
      deboger('🔒 ConversationCacheService fermé');
    } catch (e) {
      deboger('❌ Erreur fermeture cache: \$e');
    }
  }
}