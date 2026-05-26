import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/screen/client/shared/inbox/messaging_thread_screen.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_display.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversations_list_card.dart';
import 'package:asfar/screen/client/shared/inbox/widget/messaging_loading_view.dart';
import 'package:asfar/screen/client/shared/inbox/widget/messaging_search_bar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/model/user/user.dart';

/// Écran de liste des conversations — `MessagingListScreen`.
///
/// Consomme directement la liste `Conversation` du `ConversationBloc`. La
/// logique de présentation (rôle, nom interlocuteur, time, sub) est exposée
/// par l'extension `ConversationDisplay` sur `Conversation`.
class MessagingListScreen extends StatefulWidget {
  const MessagingListScreen({super.key});

  @override
  State<MessagingListScreen> createState() => _MessagingListScreenState();
}

class _MessagingListScreenState extends State<MessagingListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ConversationBloc>().add(const LoadConversations());
    });
  }

  List<Conversation> _filtered(List<Conversation> all, User? me) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((c) {
      final who = c.whoFor(me).toLowerCase();
      final sub = c.subLabel.toLowerCase();
      final last = c.lastMessagePreviewText.toLowerCase();
      return who.contains(q) || sub.contains(q) || last.contains(q);
    }).toList();
  }

  List<Conversation> _extractConversations(ConversationState state) {
    if (state is ConversationLoaded) return state.conversations;
    if (state is MessagesLoading) return state.conversations;
    if (state is MessagesLoaded) return state.conversations;
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const DynamicAppBar(
        title: 'Messages',
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final currentUser = userState.user;
          return BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, convState) {
              if (convState is ConversationLoading) {
                return const MessagingLoadingView();
              }
              if (convState is ConversationError) {
                return EmptyState.error(
                  message: convState.message,
                  onRetry: () => context.read<ConversationBloc>().add(
                      const LoadConversations(forceRefresh: true)),
                );
              }
              final conversations = _extractConversations(convState);
              final visible = _filtered(conversations, currentUser);
              return SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    MessagingSearchBar(
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                    Expanded(
                      child: conversations.isEmpty
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: EmptyState.hero(
                                icon: Icons.chat_bubble_outline,
                                title: 'Aucune conversation',
                                body:
                                    'Vos échanges avec les hôtes, locataires et démarcheurs apparaîtront ici.',
                              ),
                            )
                          : visible.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18),
                                  child: EmptyState.inline(
                                    icon: Icons.search_off_outlined,
                                    title: 'Aucune conversation trouvée',
                                    body: 'Essayez un autre mot-clé.',
                                  ),
                                )
                              : ConversationsListCard(
                                  conversations: visible,
                                  currentUser: currentUser,
                                  onTap: (c) => pushScreen(
                                    context,
                                    MessagingThreadScreen(conversation: c),
                                  ),
                                ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
