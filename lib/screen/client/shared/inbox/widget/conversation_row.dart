import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row_badge_sub.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row_last_message.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row_top_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Listrow d'une conversation — `MessagingListScreen`.
///
/// Reproduit le proto `extras.jsx::MessagingList` (lignes 110-148) :
/// `UserAvatar` 46×46 + 3 sous-rows (nom+shield+time / badge rôle+sub /
/// last message + cercle unread).
class ConversationRow extends StatelessWidget {
  final ConversationPreview conversation;
  final VoidCallback? onTap;
  final bool isLast;

  const ConversationRow({
    super.key,
    required this.conversation,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
              UserAvatar(name: conversation.who, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConversationRowTopRow(
                      name: conversation.who,
                      certified: conversation.certified,
                      time: conversation.time,
                    ),
                    const SizedBox(height: 2),
                    ConversationRowBadgeSub(
                      role: conversation.role,
                      sub: conversation.sub,
                    ),
                    const SizedBox(height: 4),
                    ConversationRowLastMessage(
                      lastMessage: conversation.lastMessage,
                      unread: conversation.unread,
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
