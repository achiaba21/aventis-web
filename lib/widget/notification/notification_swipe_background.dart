import 'package:flutter/material.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget pour l'arrière-plan lors du swipe sur une notification
class NotificationSwipeBackground extends StatelessWidget {
  const NotificationSwipeBackground({
    super.key,
    required this.notification,
    required this.isLeft,
  });

  final NotificationModel notification;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final color = isLeft ? AppColors.error : AppColors.accent;
    final icon = isLeft ? Icons.delete : Icons.mark_email_read;
    final label = isLeft ? 'Supprimer' : (notification.isUnread ? 'Marquer lu' : 'Marquer non lu');

    return Container(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 28),
          const SizedBox(height: 4),
          TextSeed(
            label,
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
