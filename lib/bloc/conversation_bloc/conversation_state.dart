import 'package:web_flutter/model/conversation/conversation.dart';
import 'package:web_flutter/model/conversation/chat_message.dart';

abstract class ConversationState {
  const ConversationState();
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationLoaded extends ConversationState {
  final List<Conversation> conversations;

  const ConversationLoaded({required this.conversations});
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError({required this.message});
}

class MessagesLoading extends ConversationState {
  final int conversationId;

  const MessagesLoading({required this.conversationId});
}

class MessagesLoaded extends ConversationState {
  final int conversationId;
  final List<ChatMessage> messages;
  final bool hasMore;

  const MessagesLoaded({
    required this.conversationId,
    required this.messages,
    this.hasMore = false,
  });
}

class MessagesError extends ConversationState {
  final int conversationId;
  final String message;

  const MessagesError({
    required this.conversationId,
    required this.message,
  });
}

class MessageSending extends ConversationState {
  final int conversationId;
  final ChatMessage tempMessage;

  const MessageSending({
    required this.conversationId,
    required this.tempMessage,
  });
}

class MessageSent extends ConversationState {
  final int conversationId;
  final ChatMessage message;

  const MessageSent({
    required this.conversationId,
    required this.message,
  });
}

class MessageSendError extends ConversationState {
  final int conversationId;
  final String message;
  final ChatMessage? failedMessage;

  const MessageSendError({
    required this.conversationId,
    required this.message,
    this.failedMessage,
  });
}

class ConversationCreating extends ConversationState {
  final int bookingId;

  const ConversationCreating({required this.bookingId});
}

class ConversationCreated extends ConversationState {
  final Conversation conversation;

  const ConversationCreated({required this.conversation});
}

class ConversationCreateError extends ConversationState {
  final int bookingId;
  final String message;

  const ConversationCreateError({
    required this.bookingId,
    required this.message,
  });
}

class NewMessageReceived extends ConversationState {
  final ChatMessage message;

  const NewMessageReceived({required this.message});
}