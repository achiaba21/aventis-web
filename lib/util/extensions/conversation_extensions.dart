import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/model/conversation/chat_message.dart';
import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/model/message/message.dart';
import 'package:web_flutter/model/user/proprietaire.dart';
import 'package:web_flutter/model/user/locataire.dart';
import 'package:web_flutter/model/user/client.dart';

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
    // Convertir User vers Client si nécessaire
    Client? clientExpedite;
    if (expediteur != null) {
      if (expediteur is Client) {
        clientExpedite = expediteur as Client;
      } else {
        // Créer un Client basé sur les données User
        clientExpedite = Client.fromJson(expediteur!.toJson());
      }
    }

    return Message(
      client: clientExpedite,
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