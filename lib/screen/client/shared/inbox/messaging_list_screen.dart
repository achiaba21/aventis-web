import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/screen/client/shared/inbox/messaging_thread_screen.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row.dart';
import 'package:asfar/screen/client/shared/inbox/widget/messaging_search_bar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/mapping/conversation_to_preview.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Écran de liste des conversations — `MessagingListScreen`.
///
/// V8.5 Lot 9 : branché sur `ConversationBloc`. La liste provient de
/// `ConversationLoaded.conversations` mappée via
/// `ConversationToPreviewMapper`. Détermination du rôle de l'interlocuteur
/// via `UserBloc.state.user`.
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

  void _onEditTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nouvelle conversation bientôt'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<ConversationPreview> _filtered(List<ConversationPreview> all) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((c) {
      return c.who.toLowerCase().contains(q) ||
          c.sub.toLowerCase().contains(q) ||
          c.lastMessage.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Messages',
        trailing: IconBoutton(
          icon: Icons.edit_outlined,
          onPressed: _onEditTap,
        ),
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final currentUser = userState.user;
          return BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, convState) {
              if (convState is ConversationLoading) return _buildLoading();
              if (convState is ConversationError) {
                return EmptyState.error(
                  message: convState.message,
                  onRetry: () => context.read<ConversationBloc>().add(
                      const LoadConversations(forceRefresh: true)),
                );
              }
              final conversations = _extractConversations(convState);
              final previews = ConversationToPreviewMapper.mapMany(
                conversations,
                currentUser: currentUser,
              );
              final visible = _filtered(previews);
              return SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    MessagingSearchBar(
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                    Expanded(
                      child: _buildBody(previews, visible),
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

  List<Conversation> _extractConversations(ConversationState state) {
    if (state is ConversationLoaded) return state.conversations;
    if (state is MessagesLoading) return state.conversations;
    if (state is MessagesLoaded) return state.conversations;
    return const [];
  }

  Widget _buildBody(List<ConversationPreview> all, List<ConversationPreview> visible) {
    if (all.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: EmptyState.hero(
          icon: Icons.chat_bubble_outline,
          title: 'Aucune conversation',
          body:
              'Vos échanges avec les hôtes, locataires et démarcheurs apparaîtront ici.',
        ),
      );
    }
    if (visible.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: EmptyState.inline(
          icon: Icons.search_off_outlined,
          title: 'Aucune conversation trouvée',
          body: 'Essayez un autre mot-clé.',
        ),
      );
    }
    return _conversationsList(visible);
  }

  Widget _buildLoading() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: const [
        ShimmerCard(height: 76),
        SizedBox(height: 10),
        ShimmerCard(height: 76),
        SizedBox(height: 10),
        ShimmerCard(height: 76),
        SizedBox(height: 10),
        ShimmerCard(height: 76),
      ],
    );
  }

  Widget _conversationsList(List<ConversationPreview> visible) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 100),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElev1,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < visible.length; i++)
              ConversationRow(
                conversation: visible[i],
                isLast: i == visible.length - 1,
                onTap: () => pushScreen(
                  context,
                  MessagingThreadScreen(conversation: visible[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
