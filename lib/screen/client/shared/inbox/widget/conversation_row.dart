import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_role_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Listrow d'une conversation — `MessagingListScreen`.
///
/// Reproduit le proto `extras.jsx::MessagingList` (lignes 110-148) :
/// `UserAvatar` 46×46 (alignTop) + 3 rows (nom+shield+time / badge rôle+sub /
/// last message + cercle unread accent or si unread > 0).
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
                    _topRow(),
                    const SizedBox(height: 2),
                    _badgeAndSubRow(),
                    const SizedBox(height: 4),
                    _lastMessageRow(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topRow() {
    return Row(
      children: [
        Flexible(
          child: Text(
            conversation.who,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (conversation.certified) ...[
          const SizedBox(width: 6),
          const Icon(Icons.verified_user_outlined,
              size: 12, color: AppColors.accent),
        ],
        const Spacer(),
        Text(
          conversation.time,
          style: AppTextStyles.small.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _badgeAndSubRow() {
    return Row(
      children: [
        BadgeStatus(
          text: ConversationRoleDisplay.labelOf(conversation.role),
          tone: ConversationRoleDisplay.toneOf(conversation.role),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '· ${conversation.sub}',
            style: AppTextStyles.small.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _lastMessageRow() {
    final hasUnread = conversation.unread > 0;
    return Row(
      children: [
        Expanded(
          child: Text(
            conversation.lastMessage,
            style: TextStyle(
              fontSize: 13,
              color: hasUnread ? AppColors.text : AppColors.text3,
              fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasUnread) ...[
          const SizedBox(width: 8),
          _unreadBadge(),
        ],
      ],
    );
  }

  Widget _unreadBadge() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accent,
      ),
      alignment: Alignment.center,
      child: Text(
        '${conversation.unread}',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}
