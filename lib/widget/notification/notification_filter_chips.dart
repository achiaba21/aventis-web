import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/util/notification_utils.dart';
import 'package:asfar/widget/notification/notification_filter_chip.dart';

/// Type de filtre pour les notifications
enum NotificationFilter {
  all,
  reservations,
  messages,
}

/// Widget de filtrage par chips pour les notifications
class NotificationFilterChips extends StatelessWidget {
  const NotificationFilterChips({
    super.key,
    required this.notifications,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final List<NotificationModel> notifications;
  final NotificationFilter selectedFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingBloc,
        vertical: Espacement.paddingBloc / 2,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            NotificationFilterChip(
              label: "Tous",
              count: notifications.length,
              icon: Icons.notifications,
              isSelected: selectedFilter == NotificationFilter.all,
              onTap: () => onFilterChanged(NotificationFilter.all),
            ),
            SizedBox(width: Espacement.gapSection),
            NotificationFilterChip(
              label: "Réservations",
              count: NotificationUtils.getReservationCount(notifications),
              icon: Icons.calendar_today,
              isSelected: selectedFilter == NotificationFilter.reservations,
              onTap: () => onFilterChanged(NotificationFilter.reservations),
            ),
            SizedBox(width: Espacement.gapSection),
            NotificationFilterChip(
              label: "Messages",
              count: NotificationUtils.getMessageCount(notifications),
              icon: Icons.message,
              isSelected: selectedFilter == NotificationFilter.messages,
              onTap: () => onFilterChanged(NotificationFilter.messages),
            ),
          ],
        ),
      ),
    );
  }
}
