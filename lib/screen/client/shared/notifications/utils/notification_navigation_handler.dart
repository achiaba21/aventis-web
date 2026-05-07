import 'package:flutter/material.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/model/notification/notification_event.dart';
import 'package:asfar/service/notification/notification_helper.dart';
import 'package:asfar/widget/notification/notification_detail_sheet.dart';

/// Handler pour gérer la navigation depuis les notifications
class NotificationNavigationHandler {
  /// Gère le tap sur une notification et navigue vers la destination appropriée
  static void handleNotificationTap({
    required BuildContext context,
    required NotificationModel notification,
  }) {
    // Marquer comme lue
    NotificationHelper.markAsReadAndNavigate(
      context: context,
      notification: notification,
      onNavigate: () => _navigateToDestination(context, notification),
    );
  }

  static void _navigateToDestination(
    BuildContext context,
    NotificationModel notification,
  ) {
    switch (notification.event) {
      case NotificationEvent.reservation:
        _handleReservationNotification(context, notification);
        break;

      case NotificationEvent.message:
        _handleMessageNotification(context, notification);
        break;

      case NotificationEvent.notification:
        _handleGenericNotification(context, notification);
        break;
    }
  }

  /// Gère les notifications de type réservation
  static void _handleReservationNotification(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Extraire les données de la notification
    final actionData = notification.actionData;

    if (actionData != null) {
      final reservationId = actionData['reservationId'];
      final appartementId = actionData['appartementId'];

      if (reservationId != null) {
        // TODO: Naviguer vers la page de détail de la réservation
        // Navigator.pushNamed(
        //   context,
        //   '/reservation-detail',
        //   arguments: {'reservationId': reservationId},
        // );

        // Pour l'instant, afficher un SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation vers réservation #$reservationId'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else if (appartementId != null) {
        // TODO: Naviguer vers l'appartement
        // Navigator.pushNamed(
        //   context,
        //   '/appartement-detail',
        //   arguments: {'appartementId': appartementId},
        // );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation vers appartement #$appartementId'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Pas de données de navigation, afficher le détail
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => NotificationDetailSheet(
            notification: notification,
          ),
        );
      }
    } else {
      // Pas d'actionData, afficher le détail
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => NotificationDetailSheet(
          notification: notification,
        ),
      );
    }
  }

  /// Gère les notifications de type message
  static void _handleMessageNotification(
    BuildContext context,
    NotificationModel notification,
  ) {
    final actionData = notification.actionData;

    if (actionData != null) {
      final conversationId = actionData['conversationId'];

      if (conversationId != null) {
        // TODO: Naviguer vers la conversation
        // Navigator.pushNamed(
        //   context,
        //   '/conversation',
        //   arguments: {
        //     'conversationId': conversationId,
        //     'messageId': messageId,
        //   },
        // );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation vers conversation #$conversationId'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Pas de conversationId, aller vers la liste des messages
        // TODO: Navigator.pushNamed(context, '/inbox');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation vers la messagerie'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Pas d'actionData, aller vers la liste des messages
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => NotificationDetailSheet(
          notification: notification,
        ),
      );
    }
  }

  /// Gère les notifications génériques
  static void _handleGenericNotification(
    BuildContext context,
    NotificationModel notification,
  ) {
    // Afficher le détail dans un bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationDetailSheet(
        notification: notification,
      ),
    );
  }
}
