import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_display.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_role_display.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';

/// Ligne badge rôle + sub-text d'une `ConversationRow`.
class ConversationRowBadgeSub extends StatelessWidget {
  final ConversationRole role;
  final String sub;

  const ConversationRowBadgeSub({
    super.key,
    required this.role,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BadgeStatus(
          text: ConversationRoleDisplay.labelOf(role),
          tone: ConversationRoleDisplay.toneOf(role),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            '· $sub',
            style: AppTextStyles.small.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
