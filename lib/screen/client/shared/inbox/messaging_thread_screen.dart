import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/conversation/chat_message.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_display.dart';
import 'package:asfar/screen/client/shared/partenariats/partenariat_detail_screen.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_detail_screen.dart';
import 'package:asfar/screen/client/shared/inbox/widget/chat_input_bar.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_custom_header.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_loading_view.dart';
import 'package:asfar/screen/client/shared/inbox/widget/thread_messages_list.dart';
import 'package:asfar/service/realtime/realtime_resource_mixin.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran de conversation 1-to-1 — `MessagingThreadScreen`.
///
/// Consomme directement le modèle métier [Conversation]. La logique de
/// présentation (nom interlocuteur, sub, phone) provient de l'extension
/// `ConversationDisplay` sur `Conversation`.
class MessagingThreadScreen extends StatefulWidget {
  final Conversation conversation;

  const MessagingThreadScreen({super.key, required this.conversation});

  @override
  State<MessagingThreadScreen> createState() => _MessagingThreadScreenState();
}

class _MessagingThreadScreenState extends State<MessagingThreadScreen>
    with RealtimeResourceMixin {
  final _scrollController = ScrollController();
  late final int _conversationId;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversation.id ?? 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _conversationId <= 0) return;
      context.read<ConversationBloc>().add(
            LoadConversationMessages(conversationId: _conversationId),
          );
      // Marque la conversation comme lue à l'ouverture (vide le badge non-lus)
      // — uniquement s'il reste des non-lus, pour éviter un appel réseau inutile.
      if (widget.conversation.hasUnreadMessages) {
        context.read<ConversationBloc>().add(
              MarkConversationAsRead(conversationId: _conversationId),
            );
      }
    });

    // Temps réel : sur le fil ouvert, un MESSAGE reçu s'insère directement
    // (payload complet) ; à la (re)connexion, on recharge le fil (catch-up).
    if (_conversationId > 0) {
      watchResource(
        topic: '/topic/seance/$_conversationId',
        onAction: (action) {
          if (!mounted || action.entityType != 'MESSAGE') return;
          context.read<ConversationBloc>().add(
                MessageReceived(
                  messageData: action.payload,
                  conversationId: _conversationId,
                ),
              );
        },
        onResync: () {
          if (!mounted) return;
          context.read<ConversationBloc>().add(
                LoadConversationMessages(conversationId: _conversationId),
              );
        },
      );
    }
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
    final me = context.read<UserBloc>().state.user;
    final phone = widget.conversation.phoneFor(me)?.trim();
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

  void _onReservationTap(Reservation? loaded) {
    if (loaded != null) {
      pushScreen(context, ReservationDetailScreen(reservation: loaded));
      return;
    }
    _toast('Détail de la réservation indisponible');
  }

  void _onPartenariatTap(DemandePartenariat? loaded) {
    if (loaded == null) {
      _toast('Détail du partenariat indisponible');
      return;
    }
    pushScreen(context, PartenariatDetailScreen(demande: loaded));
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<UserBloc>().state.user;
    final who = widget.conversation.whoFor(currentUser);
    final sub = widget.conversation.subLabel;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            ThreadCustomHeader(
              who: who,
              sub: sub,
              certified: false,
              onCall: _onCall,
            ),
            Expanded(
              child: BlocConsumer<ConversationBloc, ConversationState>(
                // Défile en bas dès que les messages de CE fil changent :
                // ouverture (load), message entrant temps réel, ou envoi.
                listenWhen: (_, curr) =>
                    curr is MessageSent ||
                    curr is NewMessageReceived ||
                    (curr is MessagesLoaded &&
                        curr.conversationId == _conversationId),
                listener: (context, state) => _scrollToBottom(),
                // Ne reconstruit la liste que pour les états qui portent les
                // messages. Les états transitoires (MessageSent, MessageSending,
                // MessageSendError…) n'en contiennent pas : sans ce filtre, le
                // builder repasse avec une liste vide → la conversation
                // « disparaît » juste après l'envoi d'un message.
                buildWhen: (_, curr) =>
                    curr is MessagesLoading ||
                    curr is MessagesLoaded ||
                    curr is MessagesError,
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
                  final messages = <ChatMessage>[];
                  if (state is MessagesLoaded &&
                      state.conversationId == _conversationId) {
                    messages.addAll(state.messages);
                  }
                  return ThreadMessagesList(
                    messages: messages,
                    currentUser: currentUser,
                    scrollController: _scrollController,
                    onReservationTap: _onReservationTap,
                    onPartenariatTap: _onPartenariatTap,
                  );
                },
              ),
            ),
            ChatInputBar(
              onSend: _onSend,
            ),
          ],
        ),
      ),
    );
  }
}
