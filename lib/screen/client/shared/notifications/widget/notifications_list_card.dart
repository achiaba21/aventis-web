import 'package:flutter/material.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/screen/client/shared/notifications/widget/notification_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card list verticale des `NotificationRow` du `NotificationsScreen`,
/// triée par `createdAt` décroissant.
class NotificationsListCard extends StatelessWidget {
  final List<NotificationModel> notifications;
  final void Function(NotificationModel n)? onTap;

  const NotificationsListCard({
    super.key,
    required this.notifications,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = List.of(notifications)
      ..sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElev1,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < sorted.length; i++)
              NotificationRow(
                notification: sorted[i],
                isLast: i == sorted.length - 1,
                onTap: onTap == null ? null : () => onTap!(sorted[i]),
              ),
          ],
        ),
      ),
    );
  }
}
