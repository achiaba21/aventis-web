import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_unread_badge.dart';
import 'package:asfar/theme/app_colors.dart';

/// Ligne dernier message d'une `ConversationRow` — texte tronqué + badge
/// unread à droite si `unread > 0`.
class ConversationRowLastMessage extends StatelessWidget {
  final String lastMessage;
  final int unread;

  const ConversationRowLastMessage({
    super.key,
    required this.lastMessage,
    required this.unread,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = unread > 0;
    return Row(
      children: [
        Expanded(
          child: Text(
            lastMessage,
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
          ConversationUnreadBadge(count: unread),
        ],
      ],
    );
  }
}
