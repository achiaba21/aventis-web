import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/client/locataire/inbox/widget/conversation_message_list.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/message/conversation_app_bar.dart';
import 'package:asfar/widget/message/send_message.dart' as widgets;

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({
    super.key,
    this.conversationId,
    required this.contactName,
    required this.currentUserId,
    this.contact,
    this.contactId,
    this.proprietaireId,
    this.locataireId,
    this.reservationReference,
  });

  final int? conversationId;
  final String contactName;
  final int currentUserId;
  final User? contact;
  final int? contactId;

  // Paramètres pour la création de conversation
  final int? proprietaireId;
  final int? locataireId;
  final String? reservationReference;

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _pendingMessage;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    deboger(['🏁 ConversationScreen initState', 'ID: ${widget.conversationId}']);

    // Charger les messages seulement si conversationId existe
    if (widget.conversationId != null) {
      context.read<ConversationBloc>().add(
        LoadConversationMessages(conversationId: widget.conversationId!),
      );
    }

    // Écouter le scroll pour le bouton "scroll to bottom"
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.offset > 200;
    if (showButton != _showScrollToBottom) {
      setState(() => _showScrollToBottom = showButton);
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ConversationCreated) {
          // Si on a un message en attente, on l'envoie
          if (_pendingMessage != null) {
            context.read<ConversationBloc>().add(
              SendMessage(
                conversationId: state.conversation.id!,
                contenu: _pendingMessage!,
              ),
            );
            _pendingMessage = null;
          }

          // On remplace l'écran actuel par le même avec l'ID de la conversation
          pushScreenAndReplace(
            context,
            ConversationScreen(
              conversationId: state.conversation.id,
              contactName: widget.contactName,
              currentUserId: widget.currentUserId,
              contact: widget.contact,
              contactId: widget.contactId,
              proprietaireId: widget.proprietaireId,
              locataireId: widget.locataireId,
              reservationReference: widget.reservationReference,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: ConversationAppBar(
          contactName: widget.contactName,
          contact: widget.contact,
          isOnline: false, // TODO: Implémenter le statut en ligne
          lastSeen: null,
        ),
        body: Column(
          children: [
            // Liste des messages
            Expanded(
              child: Stack(
                children: [
                  ConversationMessageList(
                    conversationId: widget.conversationId,
                    currentUserId: widget.currentUserId,
                    contactName: widget.contactName,
                    scrollController: _scrollController,
                  ),
                  // Bouton scroll to bottom
                  if (_showScrollToBottom)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: ScrollToBottomButton(onPressed: _scrollToBottom),
                    ),
                ],
              ),
            ),
            // Widget d'envoi de message
            widgets.SendMessage(
              conversationId: widget.conversationId,
              onSend: widget.conversationId == null
                  ? (String content) {
                      if (widget.proprietaireId != null &&
                          widget.locataireId != null) {
                        _pendingMessage = content;
                        context.read<ConversationBloc>().add(
                          CreateConversationFromBooking(
                            proprietaireId: widget.proprietaireId!,
                            locataireId: widget.locataireId!,
                            reservationReference: widget.reservationReference,
                          ),
                        );
                      }
                    }
                  : null,
              onMessageSent: () {
                if (widget.conversationId != null) {
                  context.read<ConversationBloc>().add(
                    LoadConversationMessages(
                      conversationId: widget.conversationId!,
                      forceRefresh: true,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
