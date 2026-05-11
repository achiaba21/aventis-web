import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/conversation/chat_message.dart' as model;
import 'package:asfar/model/ui_only/accepted_referral_card_payload.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/model/ui_only/reservation_card_payload.dart';
import 'package:asfar/screen/client/demarcheur/referrals/referral_detail_screen.dart';
import 'package:asfar/screen/client/locataire/booking/detail_screen.dart';
import 'package:asfar/screen/client/shared/inbox/widget/chat_input_bar.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_custom_header.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_loading_view.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_messages_list.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/mapping/chat_message_to_ui.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran de conversation 1-to-1 — `MessagingThreadScreen`.
///
/// V8.5 Lot 9 : branché sur `ConversationBloc`.
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

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _onCall() async {
    final phone = widget.conversation.phone?.trim();
    if (phone == null || phone.isEmpty) {
      _toast('Numéro indisponible');
      return;
    }
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      final ok = await launchUrl(uri);
      if (!ok && mounted) _toast('Impossible de lancer l\'appel');
    } catch (e) {
      deboger('MessagingThread.onCall: $e');
      if (mounted) _toast('Impossible de lancer l\'appel');
    }
  }

  void _onReservationTap(ReservationCardPayload payload) {
    pushScreen(context, LocataireDetailScreen(listing: payload.listing));
  }

  void _onReferralTap(AcceptedReferralCardPayload payload) {
    final referral = payload.referral;
    if (referral == null) {
      // Le mapper actuel n'enrichit pas encore le payload avec un
      // ReferralPreview complet (en attente du format backend des cards
      // [ASFAR_CARD:referral]). Toast informatif en attendant.
      _toast('Détail de la demande ${payload.referralCode} bientôt disponible');
      return;
    }
    pushScreen(context, ReferralDetailScreen(referral: referral));
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.conversation;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ThreadCustomHeader(
              who: c.who,
              sub: c.sub,
              certified: c.certified,
              onCall: _onCall,
            ),
            Expanded(
              child: BlocConsumer<ConversationBloc, ConversationState>(
                listenWhen: (_, curr) =>
                    curr is MessageSent || curr is NewMessageReceived,
                listener: (context, state) => _scrollToBottom(),
                builder: (context, state) {
                  if (state is MessagesLoading &&
                      state.conversationId == _conversationId) {
                    return const ThreadLoadingView();
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
                  final currentUser = context.read<UserBloc>().state.user;
                  final raw = <model.ChatMessage>[];
                  if (state is MessagesLoaded &&
                      state.conversationId == _conversationId) {
                    raw.addAll(state.messages);
                  }
                  final messages = ChatMessageToUiMapper.mapMany(
                    raw,
                    currentUser: currentUser,
                  );
                  return ThreadMessagesList(
                    messages: messages,
                    scrollController: _scrollController,
                    onReservationTap: _onReservationTap,
                    onReferralTap: _onReferralTap,
                  );
                },
              ),
            ),
            ChatInputBar(
              onSend: _onSend,
              onPlusTap: () => _toast('Pièce jointe disponible prochainement'),
            ),
          ],
        ),
      ),
    );
  }
}
