import 'package:flutter/material.dart';
import 'package:asfar/model/conversation/conversation.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card list verticale des `ConversationRow` du `MessagingListScreen`.
class ConversationsListCard extends StatelessWidget {
  final List<Conversation> conversations;
  final User? currentUser;
  final void Function(Conversation conversation)? onTap;

  const ConversationsListCard({
    super.key,
    required this.conversations,
    required this.currentUser,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            for (var i = 0; i < conversations.length; i++)
              ConversationRow(
                conversation: conversations[i],
                currentUser: currentUser,
                isLast: i == conversations.length - 1,
                onTap: onTap == null
                    ? null
                    : () => onTap!(conversations[i]),
              ),
          ],
        ),
      ),
    );
  }
}
