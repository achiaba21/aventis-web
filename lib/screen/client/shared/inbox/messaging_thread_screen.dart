import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/chat_message.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/screen/client/shared/inbox/sample/sample_threads.dart';
import 'package:asfar/screen/client/shared/inbox/widget/accepted_referral_message_card.dart';
import 'package:asfar/screen/client/shared/inbox/widget/chat_input_bar.dart';
import 'package:asfar/screen/client/shared/inbox/widget/message_bubble.dart';
import 'package:asfar/screen/client/shared/inbox/widget/reservation_message_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Écran de conversation 1-to-1 — `MessagingThreadScreen`.
///
/// Reproduit le proto `extras.jsx::MessagingThread` (lignes 192-287) :
/// header CUSTOM (Container borderBottom, pas DynamicAppBar) + ListView de
/// messages (bubbles + cards spéciales) + ChatInputBar sticky bottom.
///
/// Le thread est chargé depuis [SampleThreads.forConversation] selon l'id
/// de la conversation. Si l'id n'a pas de thread mock, affiche un placeholder
/// « Démarrez la conversation… » centré.
///
/// Tap send sur l'input bar ajoute le message à la liste locale via
/// `setState` puis scroll automatiquement vers le bas (decision archi V8).
class MessagingThreadScreen extends StatefulWidget {
  final ConversationPreview conversation;

  const MessagingThreadScreen({super.key, required this.conversation});

  @override
  State<MessagingThreadScreen> createState() => _MessagingThreadScreenState();
}

class _MessagingThreadScreenState extends State<MessagingThreadScreen> {
  late List<ChatMessage> _messages;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages =
        List.of(SampleThreads.forConversation(widget.conversation.id));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _nowTime() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
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
    setState(() {
      _messages.add(ChatMessage(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.me,
        text: text,
        time: _nowTime(),
      ));
    });
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
            Expanded(child: _messagesList()),
            ChatInputBar(
              onSend: _onSend,
              onPlusTap: () => _stub('Pièce jointe disponible prochainement'),
            ),
          ],
        ),
      ),
    );
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

  Widget _messagesList() {
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Démarrez la conversation…',
            style: AppTextStyles.small,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      itemCount: _messages.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, index) {
        if (index == 0) return _dateSeparator();
        return _messageItem(_messages[index - 1]);
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
        return ReservationMessageCard(
          payload: message.reservation!,
          onTap: () => _stub('Détail réservation disponible prochainement'),
        );
      case MessageKind.acceptedReferralCard:
        return AcceptedReferralMessageCard(
          payload: message.acceptedReferral!,
          onTap: () => _stub('Détail référence disponible prochainement'),
        );
    }
  }
}
