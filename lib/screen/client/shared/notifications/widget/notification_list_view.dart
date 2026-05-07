import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart';
import 'package:asfar/bloc/notification_bloc/notification_state.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/service/notification/notification_helper.dart';
import 'package:asfar/widget/notification/notification_tile_enhanced.dart';

/// Widget enrichi pour afficher la liste des notifications avec interactions
class NotificationListView extends StatelessWidget {
  const NotificationListView({
    super.key,
    required this.notifications,
  });

  final List<NotificationModel> notifications;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listener: (context, state) {
        // Écouter les événements de succès/erreur
        if (state is NotificationActionSuccess) {
          // Le snackbar est déjà géré par le helper
        } else if (state is NotificationError) {
          NotificationHelper.showError(
            context: context,
            message: state.message,
          );
        } else if (state is NotificationReceivedState) {
          // Nouvelle notification reçue (déjà affiché par WebSocketInitializer)
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          // Déclencher le refresh
          context.read<NotificationBloc>().add(const RefreshNotifications());

          // Attendre un peu pour le feedback visuel
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: notifications.isEmpty
            ? _buildEmptyListView(context)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationItem(context, notification);
                },
              ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, NotificationModel notification) {
    return NotificationTileEnhanced(
      notification: notification,
      onMarkAsRead: () {
        // Toggle le statut lu/non lu
        NotificationHelper.toggleReadStatus(
          context: context,
          notification: notification,
        );
      },
      onDelete: () {
        // Supprimer la notification (sans confirmation pour le swipe)
        NotificationHelper.deleteNotification(
          context: context,
          notification: notification,
        );
      },
    );
  }

  /// Widget pour gérer le pull-to-refresh quand la liste est vide
  Widget _buildEmptyListView(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(
          height: 200,
          child: Center(
            child: Text(''),
          ),
        ),
      ],
    );
  }
}
