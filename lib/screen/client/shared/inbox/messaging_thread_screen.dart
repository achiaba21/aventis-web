import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/conversation/chat_message.dart' as model;
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/screen/client/shared/inbox/widget/accepted_referral_message_card.dart';
import 'package:asfar/screen/client/shared/inbox/widget/chat_input_bar.dart';
import 'package:asfar/screen/client/shared/inbox/widget/message_bubble.dart';
import 'package:asfar/screen/client/shared/inbox/widget/reservation_message_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/mapping/chat_message_to_ui.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Écran de conversation 1-to-1 — `MessagingThreadScreen`.
///
/// V8.5 Lot 9 : branché sur `ConversationBloc`. Les messages proviennent
/// de `MessagesLoaded.messages` mappés via `ChatMessageToUiMapper` (avec
/// détection du `MessageKind` par préfixe). L'envoi déclenche `SendMessage`,
/// le scroll auto-bottom est conservé.
class MessagingThreadScreen extends StatefulWidget {
  final ConversationPreview conversation;

  const MessagingThreadScreen({super.key, required this.conversation});

  @override
  State<MessagingThreadScreen> createState() => _MessagingThreadScreenState();
}

class _MessagingThreadScreenState extends State<MessagingThreadScreen> {
  final _scrollController = ScrollController();
  late final int _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = int.tryParse(widget.conversation.id) ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _conversationId <= 0) return;
      context.read<ConversationBloc>().add(
            LoadConversationMessages(conversationId: _conversationId),
          );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _onSend(String text) {
    if (text.trim().isEmpty || _conversationId <= 0) return;
    context.read<ConversationBloc>().add(
          SendMessage(conversationId: _conversationId, contenu: text.trim()),
        );
    _scrollToBottom();
  }

  void _stub(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _customHeader(),
            Expanded(
              child: BlocConsumer<ConversationBloc, ConversationState>(
                listenWhen: (_, curr) =>
                    curr is MessageSent || curr is NewMessageReceived,
                listener: (context, state) => _scrollToBottom(),
                builder: (context, state) {
                  if (state is MessagesLoading &&
                      state.conversationId == _conversationId) {
                    return _buildLoading();
                  }
                  if (state is MessagesError &&
                      state.conversationId == _conversationId) {
                    return EmptyState.error(
                      message: state.message,
                      onRetry: () =>
                          context.read<ConversationBloc>().add(
                                LoadConversationMessages(
                                  conversationId: _conversationId,
                                  forceRefresh: true,
                                ),
                              ),
                    );
                  }
                  final messages = _extractMessages(state);
                  return _messagesList(messages);
                },
              ),
            ),
            ChatInputBar(
              onSend: _onSend,
              onPlusTap: () => _stub('Pièce jointe disponible prochainement'),
            ),
          ],
        ),
      ),
    );
  }

  List<ChatMessage> _extractMessages(ConversationState state) {
    final currentUser = context.read<UserBloc>().state.user;
    final raw = <model.ChatMessage>[];
    if (state is MessagesLoaded && state.conversationId == _conversationId) {
      raw.addAll(state.messages);
    }
    return ChatMessageToUiMapper.mapMany(raw, currentUser: currentUser);
  }

  Widget _customHeader() {
    final c = widget.conversation;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: Row(
        children: [
          IconBoutton(
            icon: Icons.arrow_back_ios_new,
            onPressed: () => back(context),
          ),
          const SizedBox(width: 8),
          UserAvatar(name: c.who, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        c.who,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (c.certified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified_user_outlined,
                          size: 12, color: AppColors.accent),
                    ],
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  c.sub,
                  style: AppTextStyles.small.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconBoutton(
            icon: Icons.phone_outlined,
            onPressed: () => _stub('Appel disponible prochainement'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      children: const [
        ShimmerCard(height: 48),
        SizedBox(height: 8),
        ShimmerCard(height: 48),
        SizedBox(height: 8),
        ShimmerCard(height: 48),
      ],
    );
  }

  Widget _messagesList(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: EmptyState.inline(
          icon: Icons.chat_outlined,
          title: 'Démarrez la conversation',
          body: 'Envoyez un premier message pour briser la glace.',
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      itemCount: messages.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, index) {
        if (index == 0) return _dateSeparator();
        return _messageItem(messages[index - 1]);
      },
    );
  }

  Widget _dateSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Text(
          "Aujourd'hui",
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
      ),
    );
  }

  Widget _messageItem(ChatMessage message) {
    switch (message.kind) {
      case MessageKind.text:
        return MessageBubble(message: message);
      case MessageKind.reservationCard:
        if (message.reservation == null) {
          return MessageBubble(message: message);
        }
        return ReservationMessageCard(
          payload: message.reservation!,
          onTap: () => _stub('Détail réservation disponible prochainement'),
        );
      case MessageKind.acceptedReferralCard:
        if (message.acceptedReferral == null) {
          return MessageBubble(message: message);
        }
        return AcceptedReferralMessageCard(
          payload: message.acceptedReferral!,
          onTap: () => _stub('Détail référence disponible prochainement'),
        );
    }
  }
}
