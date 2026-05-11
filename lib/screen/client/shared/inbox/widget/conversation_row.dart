import 'package:flutter/material.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_display.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row_badge_sub.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row_last_message.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row_top_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Listrow d'une conversation — `MessagingListScreen`.
///
/// Consomme directement le modèle métier [Conversation] + le `currentUser`
/// pour déterminer l'interlocuteur et son rôle. Reproduit le proto
/// `extras.jsx::MessagingList` (lignes 110-148) : `UserAvatar` 46×46 + 3
/// sous-rows (nom+shield+time / badge rôle+sub / last message + cercle unread).
class ConversationRow extends StatelessWidget {
  final Conversation conversation;
  final User? currentUser;
  final VoidCallback? onTap;
  final bool isLast;

  const ConversationRow({
    super.key,
    required this.conversation,
    required this.currentUser,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final who = conversation.whoFor(currentUser);
    final role = conversation.roleFor(currentUser);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.line, width: 1),
                  ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: who, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConversationRowTopRow(
                      name: who,
                      certified: false,
                      time: conversation.timeLabel,
                    ),
                    const SizedBox(height: 2),
                    ConversationRowBadgeSub(
                      role: role,
                      sub: conversation.subLabel,
                    ),
                    const SizedBox(height: 4),
                    ConversationRowLastMessage(
                      lastMessage: conversation.lastMessagePreviewText,
                      unread: conversation.unreadCountSafe,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
