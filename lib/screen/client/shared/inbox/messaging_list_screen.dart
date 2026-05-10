import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/screen/client/shared/inbox/messaging_thread_screen.dart';
import 'package:asfar/screen/client/shared/inbox/sample/sample_conversations.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row.dart';
import 'package:asfar/screen/client/shared/inbox/widget/messaging_search_bar.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Écran de liste des conversations — `MessagingListScreen`.
///
/// Adaptatif au rôle : lit `UserBloc.state.user?.type` via `BlocBuilder` et
/// charge le mock correspondant depuis [SampleConversations.forRole].
/// Fallback locataire si rôle inconnu (cohérence proto extras.jsx:98).
///
/// Search bar filtre la liste localement (case-insensitive sur who, sub,
/// lastMessage).
class MessagingListScreen extends StatefulWidget {
  const MessagingListScreen({super.key});

  @override
  State<MessagingListScreen> createState() => _MessagingListScreenState();
}

class _MessagingListScreenState extends State<MessagingListScreen> {
  String _searchQuery = '';

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
        builder: (context, state) {
          final allConvos = SampleConversations.forRole(state.user?.type);
          final visible = _filtered(allConvos);
          return SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 6),
                MessagingSearchBar(
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? _emptyResults()
                      : _conversationsList(visible),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _emptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Aucune conversation trouvée.',
          style: AppTextStyles.small,
          textAlign: TextAlign.center,
        ),
      ),
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
