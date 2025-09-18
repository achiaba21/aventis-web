import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/model/conversation/chat_message.dart';
import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/model/message/message.dart';
import 'package:web_flutter/model/user/proprietaire.dart';
import 'package:web_flutter/model/user/locataire.dart';

/// Extensions pour mapper entre les modèles BLoC et Provider
extension ConversationToSeance on Conversation {
  /// Convertit une Conversation (BLoC) vers Seance (Provider)
  Seance toSeance() {
    final seance = Seance(
      proprietaire: proprietaire as Proprietaire?,
      locataire: locataire as Locataire?,
      dateDebut: dateDebut,
      dateFin: dateFin,
      active: active,
    );

    // Convertir les messages
    if (messages != null) {
      seance.message = messages!.map((msg) => msg.toMessage(seance)).toList();
    }

    return seance;
  }
}

extension ChatMessageToMessage on ChatMessage {
  /// Convertit un ChatMessage (BLoC) vers Message (Provider)
  Message toMessage(Seance? seance) {
    return Message(
      client: expediteur as dynamic, // Cast nécessaire
      seance: seance,
      contenu: contenu,
    )..createdAt = createdAt;
  }
}

extension SeanceToConversation on Seance {
  /// Convertit une Seance (Provider) vers Conversation (BLoC)
  Conversation toConversation() {
    return Conversation(
      proprietaire: proprietaire,
      locataire: locataire,
      dateDebut: dateDebut,
      dateFin: dateFin,
      active: active,
      messages: message.map((msg) => msg.toChatMessage()).toList(),
      lastUpdated: DateTime.now(),
      lastMessage: message.isNotEmpty ? message.last.toChatMessage() : null,
    );
  }
}

extension MessageToChatMessage on Message {
  /// Convertit un Message (Provider) vers ChatMessage (BLoC)
  ChatMessage toChatMessage() {
    return ChatMessage(
      expediteur: client,
      contenu: contenu,
      createdAt: createdAt,
      isRead: true, // Assume read for existing messages
    );
  }
}