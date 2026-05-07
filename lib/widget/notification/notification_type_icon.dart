import 'package:flutter/material.dart';
import 'package:asfar/model/notification/notification_event.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget pour afficher l'icône du type de notification
class NotificationTypeIcon extends StatelessWidget {
  const NotificationTypeIcon({
    super.key,
    required this.event,
  });

  final NotificationEvent event;

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (event) {
      case NotificationEvent.reservation:
        icon = Icons.calendar_today;
        color = AppColors.success; // Green
        break;
      case NotificationEvent.message:
        icon = Icons.message;
        color = AppColors.info; // Blue
        break;
      case NotificationEvent.notification:
        icon = Icons.notifications;
        color = AppColors.accent;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 20,
        color: color,
      ),
    );
  }
}
