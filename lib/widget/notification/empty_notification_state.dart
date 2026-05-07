import 'package:flutter/material.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget réutilisable pour afficher un état vide dans les notifications
class EmptyNotificationState extends StatelessWidget {
  const EmptyNotificationState({
    super.key,
    this.icon = Icons.notifications_none,
    this.title = "Aucune notification",
    this.message = "Vous n'avez aucune notification pour le moment",
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.textPrimary.withValues(alpha: 0.3)),
            const SizedBox(height: 24),
            TextSeed(
              title,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: 8),
            TextSeed(
              message,
              textAlign: TextAlign.center,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 32),
              PlainButton(
                value: actionLabel!,
                onPress: onActionPressed!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
