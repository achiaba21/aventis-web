import 'package:flutter/material.dart';
import 'package:asfar/model/notification/notification_event.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget pour afficher le badge du type d'événement de notification
class NotificationEventBadge extends StatelessWidget {
  const NotificationEventBadge({
    super.key,
    required this.event,
  });

  final NotificationEvent event;

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    switch (event) {
      case NotificationEvent.reservation:
        label = 'Réservation';
        color = AppColors.success; // Green
        break;
      case NotificationEvent.message:
        label = 'Message';
        color = AppColors.info; // Blue
        break;
      case NotificationEvent.notification:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: TextSeed(
        label,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}
