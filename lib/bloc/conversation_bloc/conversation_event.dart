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

class MarkMessageAsRead extends ConversationEvent {
  final int conversationId;
  final int messageId;

  const MarkMessageAsRead({
    required this.conversationId,
    required this.messageId,
  });
}

class CreateConversationFromBooking extends ConversationEvent {
  final int bookingId;

  const CreateConversationFromBooking({required this.bookingId});
}

class MessageReceived extends ConversationEvent {
  final dynamic messageData;

  const MessageReceived({required this.messageData});
}

class ConversationUpdated extends ConversationEvent {
  final dynamic conversationData;

  const ConversationUpdated({required this.conversationData});
}

class ClearConversations extends ConversationEvent {
  const ClearConversations();
}

class SetCurrentUser extends ConversationEvent {
  final dynamic user;

  const SetCurrentUser({required this.user});
}