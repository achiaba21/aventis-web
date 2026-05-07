import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/widget/message/conversation_empty_state.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/message/message_item.dart';

/// Widget contenant la liste des messages avec états loading/error
class ConversationMessageList extends StatelessWidget {
  final int? conversationId;
  final int currentUserId;
  final String contactName;
  final ScrollController scrollController;

  const ConversationMessageList({
    super.key,
    required this.conversationId,
    required this.currentUserId,
    required this.contactName,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConversationBloc, ConversationState>(
      builder: (context, state) {
        // Loading
        if (state is MessagesLoading || state is ConversationCreating) {
          return const MessagesLoadingView();
        }

        // Erreur
        if (state is MessagesError || state is ConversationCreateError) {
          String message = "Une erreur est survenue";
          if (state is MessagesError) message = state.message;
          if (state is ConversationCreateError) message = state.message;

          return MessagesErrorView(
            message: message,
            onRetry: conversationId != null
                ? () {
                    context.read<ConversationBloc>().add(
                      LoadConversationMessages(
                        conversationId: conversationId!,
                        forceRefresh: true,
                      ),
                    );
                  }
                : null,
          );
        }

        // Messages chargés
        if (state is MessagesLoaded &&
            conversationId != null &&
            state.conversationId == conversationId) {
          final messages = state.messages;

          if (messages.isEmpty) {
            return ConversationEmptyState(
              contactName: contactName,
              isNewConversation: false,
            );
          }

          return MessageListView(
            messages: messages,
            currentUserId: currentUserId,
            scrollController: scrollController,
          );
        }

        // État initial / nouvelle conversation
        if (state is ConversationCreated) {
          return const MessagesLoadingView();
        }

        // Nouvelle conversation (pas d'ID)
        if (conversationId == null) {
          return ConversationEmptyState(
            contactName: contactName,
            isNewConversation: true,
          );
        }

        return ConversationEmptyState(
          contactName: contactName,
          isNewConversation: false,
        );
      },
    );
  }
}

/// Widget de liste des messages avec groupement et séparateurs
class MessageListView extends StatelessWidget {
  final List<ChatMessage> messages;
  final int currentUserId;
  final ScrollController scrollController;

  const MessageListView({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final items = _buildMessageItems();

    return ListView.builder(
      controller: scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    );
  }

  List<Widget> _buildMessageItems() {
    if (messages.isEmpty) return [];

    final items = <Widget>[];
    DateTime? currentDate;

    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final messageDate = message.createdAt;
      final senderId = message.expediteur?.id;
      final isCurrentUser = senderId == currentUserId;

      if (messageDate != null) {
        final dateOnly = DateTime(messageDate.year, messageDate.month, messageDate.day);
        if (currentDate == null || currentDate != dateOnly) {
          items.add(DateSeparator(date: messageDate));
          currentDate = dateOnly;
        }
      }

      final position = _getMessagePosition(i);

      items.add(
        MessageItem(
          message,
          isCurrentUser: isCurrentUser,
          position: position,
          showAvatar: !isCurrentUser,
          showTime: position == MessagePosition.single || position == MessagePosition.last,
        ),
      );
    }

    return items.reversed.toList();
  }

  MessagePosition _getMessagePosition(int index) {
    final message = messages[index];
    final senderId = message.expediteur?.id;
    final messageDate = message.createdAt;

    final prevIndex = index - 1;
    final bool sameAsPrev = prevIndex >= 0 &&
        messages[prevIndex].expediteur?.id == senderId &&
        _isSameDay(messageDate, messages[prevIndex].createdAt);

    final nextIndex = index + 1;
    final bool sameAsNext = nextIndex < messages.length &&
        messages[nextIndex].expediteur?.id == senderId &&
        _isSameDay(messageDate, messages[nextIndex].createdAt);

    if (sameAsPrev && sameAsNext) {
      return MessagePosition.middle;
    } else if (sameAsPrev && !sameAsNext) {
      return MessagePosition.last;
    } else if (!sameAsPrev && sameAsNext) {
      return MessagePosition.first;
    } else {
      return MessagePosition.single;
    }
  }

  bool _isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Bouton pour scroller vers le bas
class ScrollToBottomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScrollToBottomButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: AppColors.surface,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.surface, width: 0.5),
          ),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
