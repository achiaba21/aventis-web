import 'package:flutter/material.dart';
import 'package:asfar/model/ui_only/conversation_preview.dart';
import 'package:asfar/screen/client/shared/inbox/widget/conversation_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card list verticale des `ConversationRow` du `MessagingListScreen`.
class ConversationsListCard extends StatelessWidget {
  final List<ConversationPreview> conversations;
  final void Function(ConversationPreview conversation)? onTap;

  const ConversationsListCard({
    super.key,
    required this.conversations,
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
