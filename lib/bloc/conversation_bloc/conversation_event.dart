import 'package:asfar/model/user/user.dart';

abstract class ConversationEvent {
  const ConversationEvent();
}

class LoadConversations extends ConversationEvent {
  final bool forceRefresh;

  const LoadConversations({this.forceRefresh = false});
}

class LoadConversationMessages extends ConversationEvent {
  final int conversationId;
  final bool forceRefresh;
  final int? page;
  final int? limit;

  const LoadConversationMessages({
    required this.conversationId,
    this.forceRefresh = false,
    this.page,
    this.limit,
  });
}

class SendMessage extends ConversationEvent {
  final int conversationId;
  final String contenu;

  const SendMessage({
    required this.conversationId,
    required this.contenu,
  });
}

class MarkConversationAsRead extends ConversationEvent {
  final int conversationId;

  const MarkConversationAsRead({required this.conversationId});
}

class CreateConversationFromBooking extends ConversationEvent {
  final int proprietaireId;
  final int locataireId;
  final String? reservationReference;

  const CreateConversationFromBooking({
    required this.proprietaireId,
    required this.locataireId,
    this.reservationReference,
  });
}

class MessageReceived extends ConversationEvent {
  final Map<String, dynamic> messageData;

  /// Conversation cible quand le payload temps réel ne porte pas de
  /// `seanceId`/`conversationId` (ex. frame du topic `/topic/seance/{id}`,
  /// dont l'écran connaît l'identifiant mais pas forcément le payload).
  final int? conversationId;

  const MessageReceived({required this.messageData, this.conversationId});
}
  
class ConversationUpdated extends ConversationEvent {
  final Map<String, dynamic> conversationData;

  const ConversationUpdated({required this.conversationData});
}

class ClearConversations extends ConversationEvent {
  const ClearConversations();
}

class SetCurrentUser extends ConversationEvent {
  final User user;

  const SetCurrentUser({required this.user});
}

// ==================== RÉINITIALISATION ====================

/// Réinitialise le BLoC à son état Initial
class ResetConversationState extends ConversationEvent {
  const ResetConversationState();
}

/// Charger le nombre de messages non lus
class LoadUnreadCount extends ConversationEvent {
  const LoadUnreadCount();
}