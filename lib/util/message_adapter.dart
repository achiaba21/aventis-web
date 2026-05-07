import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/model/message/seance.dart';
import 'package:asfar/model/message/message.dart';
import 'package:asfar/model/user/user.dart';

/// Utilitaires pour convertir entre les modèles API (Seance/Message)
/// et les modèles UI (Conversation/ChatMessage)
class MessageAdapter {
  /// Convertir Seance → Conversation
  static Conversation seanceToConversation(Seance seance, int currentUserId) {
    // Créer des User simplifiés à partir des IDs et noms
    final proprietaire = seance.proprietaireId != null
        ? User(
            id: seance.proprietaireId,
            nom: seance.proprietaireNom?.split(' ').last ?? '',
            prenom: seance.proprietaireNom?.split(' ').first ?? '',
          )
        : null;

    final locataire = seance.locataireId != null
        ? User(
            id: seance.locataireId,
            nom: seance.locataireNom?.split(' ').last ?? '',
            prenom: seance.locataireNom?.split(' ').first ?? '',
          )
        : null;

    // Convertir le dernier message si disponible
    final lastMessage = seance.dernierMessage != null
        ? messageToChat(seance.dernierMessage!, currentUserId)
        : null;

    return Conversation(
      id: seance.id,
      proprietaire: proprietaire,
      locataire: locataire,
      dateDebut: seance.createdAt,
      dateFin: null,
      active: seance.active,
      bookingId: null,
      messages: [],
      lastUpdated: seance.createdAt ?? DateTime.now(),
      lastMessage: lastMessage,
      unreadCount: seance.messagesNonLus ?? 0,
    );
  }

  /// Convertir Message → ChatMessage
  static ChatMessage messageToChat(Message message, int currentUserId) {
    // Créer un User à partir des infos du message
    final expediteur = message.clientId != null
        ? User(
            id: message.clientId,
            nom: message.clientNom?.split(' ').last ?? '',
            prenom: message.clientNom?.split(' ').first ?? '',
          )
        : null;

    return ChatMessage(
      id: message.id,
      expediteur: expediteur,
      contenu: message.contenu,
      createdAt: message.createdAt,
      conversationId: null, // sera défini par le BLoC
      isRead: message.lu ?? false,
      isSending: false,
      hasFailed: false,
      tempId: null,
    );
  }

  /// Convertir une liste de Seances → Conversations
  static List<Conversation> seancesToConversations(
    List<Seance> seances,
    int currentUserId,
  ) {
    return seances.map((s) => seanceToConversation(s, currentUserId)).toList();
  }

  /// Convertir une liste de Messages → ChatMessages
  static List<ChatMessage> messagesToChats(
    List<Message> messages,
    int currentUserId,
    int seanceId,
  ) {
    return messages.map((m) {
      final chat = messageToChat(m, currentUserId);
      return chat.copyWith(conversationId: seanceId);
    }).toList();
  }
}
