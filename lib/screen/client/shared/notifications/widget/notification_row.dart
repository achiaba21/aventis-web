import 'package:flutter/material.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/notification/notification_event.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Une ligne de la liste `NotificationsScreen`.
///
/// Reproduit le design des `ConversationRow` / `PendingRequestRow` (icône
/// circulaire à gauche, titre + sous-texte, timeAgo + dot unread à droite).
class NotificationRow extends StatelessWidget {
  final NotificationModel notification;
  final bool isLast;
  final VoidCallback? onTap;

  const NotificationRow({
    super.key,
    required this.notification,
    this.isLast = false,
    this.onTap,
  });

  IconData _iconFor(NotificationEvent e) {
    switch (e) {
      case NotificationEvent.reservation:
        return Icons.event_available_outlined;
      case NotificationEvent.message:
        return Icons.chat_bubble_outline;
      case NotificationEvent.notification:
        return Icons.notifications_active_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unread = notification.isUnread;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: unread ? AppColors.accentSoft : AppColors.bgElev2,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              alignment: Alignment.center,
              child: Icon(
                _iconFor(notification.event),
                size: 20,
                color: unread ? AppColors.accent : AppColors.text2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.displayTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                      color: AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.contenu != null &&
                      notification.contenu!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      notification.contenu!,
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  notification.timeAgo,
                  style: AppTextStyles.small.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 6),
                if (unread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
