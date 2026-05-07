import 'package:flutter/material.dart';
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/notification/notification_event.dart' as model;
import 'package:asfar/screen/client/shared/notifications/widget/notification_list_view.dart';
import 'package:asfar/service/notification/notification_helper.dart';
import 'package:asfar/util/notification_utils.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/notification/empty_notification_state.dart';
import 'package:asfar/widget/notification/notification_filter_chips.dart';
import 'package:asfar/widget/notification/notification_list_header.dart';

/// Contenu principal de l'écran notifications
class NotificationsContent extends StatelessWidget {
  final NotificationState state;
  final NotificationFilter selectedFilter;
  final Function(NotificationFilter) onFilterChanged;

  const NotificationsContent({
    super.key,
    required this.state,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (state is NotificationInitial || state is NotificationLoading) {
      return const ListShimmer(itemCount: 8);
    }

    if (state is NotificationError) {
      return EmptyNotificationState(
        icon: Icons.error_outline,
        title: "Erreur de chargement",
        message: (state as NotificationError).message,
        actionLabel: "Réessayer",
        onActionPressed: () => NotificationHelper.refreshNotifications(context),
      );
    }

    if (state is NotificationLoaded ||
        state is NotificationReceivedState ||
        state is NotificationActionSuccess ||
        state is WebSocketConnecting ||
        state is WebSocketConnected ||
        state is WebSocketDisconnected ||
        state is WebSocketError) {
      final notifications = NotificationUtils.getNotifications(state);
      final unreadCount = NotificationUtils.getUnreadCount(state);

      if (notifications.isEmpty) {
        return const EmptyNotificationState();
      }

      final filteredNotifications = _filterNotifications(notifications);

      return Column(
        children: [
          NotificationListHeader(
            totalCount: notifications.length,
            unreadCount: unreadCount,
            onMarkAllAsRead: unreadCount > 0
                ? () => NotificationHelper.markAllAsReadWithConfirm(
                      context: context,
                      unreadCount: unreadCount,
                    )
                : null,
            onClearAll: notifications.isNotEmpty
                ? () => NotificationHelper.clearAllNotificationsWithConfirm(
                      context: context,
                      totalCount: notifications.length,
                    )
                : null,
          ),
          NotificationFilterChips(
            notifications: notifications,
            selectedFilter: selectedFilter,
            onFilterChanged: onFilterChanged,
          ),
          Expanded(
            child: filteredNotifications.isEmpty
                ? NotificationEmptyFilterState(selectedFilter: selectedFilter)
                : NotificationListView(notifications: filteredNotifications),
          ),
        ],
      );
    }

    return const EmptyNotificationState();
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
    switch (selectedFilter) {
      case NotificationFilter.all:
        return notifications;
      case NotificationFilter.reservations:
        return notifications
            .where((n) => n.event == model.NotificationEvent.reservation)
            .toList();
      case NotificationFilter.messages:
        return notifications
            .where((n) => n.event == model.NotificationEvent.message)
            .toList();
    }
  }
}

/// État vide pour un filtre spécifique
class NotificationEmptyFilterState extends StatelessWidget {
  final NotificationFilter selectedFilter;

  const NotificationEmptyFilterState({
    super.key,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String message;
    IconData icon;

    switch (selectedFilter) {
      case NotificationFilter.reservations:
        title = "Aucune réservation";
        message = "Vous n'avez pas de notifications de réservation";
        icon = Icons.calendar_today;
        break;
      case NotificationFilter.messages:
        title = "Aucun message";
        message = "Vous n'avez pas de notifications de message";
        icon = Icons.message;
        break;
      case NotificationFilter.all:
        title = "Aucune notification";
        message = "Vous n'avez aucune notification";
        icon = Icons.notifications_none;
        break;
    }

    return EmptyNotificationState(
      icon: icon,
      title: title,
      message: message,
    );
  }
}
