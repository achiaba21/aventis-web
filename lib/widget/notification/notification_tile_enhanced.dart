import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/notification/notification_event.dart';
import 'package:asfar/screen/client/shared/notifications/utils/notification_navigation_handler.dart';
import 'package:asfar/widget/date/date_format.dart';
import 'package:asfar/widget/item/circle_icon.dart';
import 'package:asfar/widget/notification/notification_event_badge.dart';
import 'package:asfar/widget/notification/notification_swipe_background.dart';
import 'package:asfar/widget/notification/notification_type_icon.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget amélioré pour afficher une notification avec interactions
class NotificationTileEnhanced extends StatelessWidget {
  const NotificationTileEnhanced({
    super.key,
    required this.notification,
    this.onMarkAsRead,
    this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe left to delete
          return true;
        } else if (direction == DismissDirection.startToEnd) {
          // Swipe right to mark as read/unread
          onMarkAsRead?.call();
          return false; // Don't actually dismiss
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      background: NotificationSwipeBackground(notification: notification, isLeft: false),
      secondaryBackground: NotificationSwipeBackground(notification: notification, isLeft: true),
      child: InkWell(
        onTap: () {
          NotificationNavigationHandler.handleNotificationTap(
            context: context,
            notification: notification,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: Espacement.paddingBloc,
            vertical: Espacement.paddingBloc,
          ),
          decoration: BoxDecoration(
            color: notification.isUnread
                ? AppColors.accent.withValues(alpha: 0.05)
                : AppColors.background,
            border: Border(
              bottom: BorderSide(
                color: AppColors.textPrimary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicateur de statut (lu/non lu)
              CircleIcon(
                image: Icons.circle,
                color: notification.isUnread ? AppColors.accent : AppColors.textPrimary.withValues(alpha: 0.3),
                size: 12,
              ),
              SizedBox(width: Espacement.gapSection),

              // Icône du type de notification
              NotificationTypeIcon(event: notification.event),
              SizedBox(width: Espacement.gapSection),

              // Contenu de la notification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête: titre + date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextSeed(
                            notification.displayTitle,
                            fontSize: 15,
                            fontWeight: notification.isUnread
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: Espacement.gapSection / 2),
                        if (notification.createdAt != null)
                          TextSeed(
                            DateFormatUtils.formatRelativeShort(notification.createdAt!),
                            fontSize: 12,
                            color: AppColors.textPrimary.withValues(alpha: 0.5),
                          ),
                      ],
                    ),

                    // Contenu
                    if (notification.contenu != null) ...[
                      SizedBox(height: Espacement.gapSection / 2),
                      TextSeed(
                        notification.contenu!,
                        maxLines: 2,
                        fontSize: 14,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                    ],

                    // Badge du type d'événement
                    if (notification.event != NotificationEvent.notification) ...[
                      SizedBox(height: Espacement.gapSection / 2),
                      NotificationEventBadge(event: notification.event),
                    ],
                  ],
                ),
              ),

              SizedBox(width: Espacement.gapSection / 2),

              // Flèche de navigation
              CircleIcon(
                image: Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textPrimary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
