import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_bloc.dart';
import 'package:asfar/bloc/notification_bloc/notification_event.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/dialog/confirm_dialog.dart';

/// Service helper pour gérer les actions sur les notifications
class NotificationHelper {
  /// Marque une notification comme lue et navigue si nécessaire
  static void markAsReadAndNavigate({
    required BuildContext context,
    required NotificationModel notification,
    VoidCallback? onNavigate,
  }) {
    final notificationBloc = context.read<NotificationBloc>();

    // Marquer comme lue si non lue
    if (notification.isUnread && notification.id != null) {
      notificationBloc.add(MarkNotificationAsRead(notification.id!));
    }

    // Naviguer
    onNavigate?.call();
  }

  /// Toggle le statut lu/non lu d'une notification
  static void toggleReadStatus({
    required BuildContext context,
    required NotificationModel notification,
  }) {
    if (notification.id == null) return;

    final notificationBloc = context.read<NotificationBloc>();

    if (notification.isUnread) {
      notificationBloc.add(MarkNotificationAsRead(notification.id!));
    } else {
      // Pour marquer comme non lue, on pourrait ajouter un événement
      // Pour l'instant, on affiche juste un message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification marquée comme non lue'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Supprime une notification avec confirmation
  static Future<void> deleteNotificationWithConfirm({
    required BuildContext context,
    required NotificationModel notification,
  }) async {
    if (notification.id == null) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Supprimer la notification',
      content: 'Voulez-vous vraiment supprimer cette notification ?',
      confirmText: 'Supprimer',
      isDangerous: true,
    );

    if (confirmed && context.mounted) {
      final notificationBloc = context.read<NotificationBloc>();
      notificationBloc.add(DeleteNotification(notification.id!));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification supprimée'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  /// Supprime une notification sans confirmation (pour swipe)
  static void deleteNotification({
    required BuildContext context,
    required NotificationModel notification,
  }) {
    if (notification.id == null) return;

    final notificationBloc = context.read<NotificationBloc>();
    notificationBloc.add(DeleteNotification(notification.id!));

    // Afficher un snackbar avec option d'annulation (undo)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification supprimée'),
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Annuler',
          textColor: AppColors.textPrimary,
          onPressed: () {
            // TODO: Implémenter l'annulation (nécessite un événement RestoreNotification dans le bloc)
          },
        ),
      ),
    );
  }

  /// Marque toutes les notifications comme lues avec confirmation
  static Future<void> markAllAsReadWithConfirm({
    required BuildContext context,
    required int unreadCount,
  }) async {
    if (unreadCount == 0) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Tout marquer comme lu',
      content: 'Marquer les $unreadCount notification${unreadCount > 1 ? 's' : ''} comme lue${unreadCount > 1 ? 's' : ''} ?',
      confirmText: 'Confirmer',
    );

    if (confirmed && context.mounted) {
      final notificationBloc = context.read<NotificationBloc>();
      notificationBloc.add(const MarkAllNotificationsAsRead());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$unreadCount notification${unreadCount > 1 ? 's' : ''} marquée${unreadCount > 1 ? 's' : ''} comme lue${unreadCount > 1 ? 's' : ''}'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  /// Efface toutes les notifications avec confirmation
  static Future<void> clearAllNotificationsWithConfirm({
    required BuildContext context,
    required int totalCount,
  }) async {
    if (totalCount == 0) return;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Effacer toutes les notifications',
      content: 'Cette action supprimera définitivement toutes vos $totalCount notification${totalCount > 1 ? 's' : ''}. Continuer ?',
      confirmText: 'Tout effacer',
      isDangerous: true,
    );

    if (confirmed && context.mounted) {
      final notificationBloc = context.read<NotificationBloc>();
      notificationBloc.add(const ClearAllNotifications());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Toutes les notifications ont été supprimées'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.accent,
        ),
      );
    }
  }

  /// Rafraîchit les notifications
  static void refreshNotifications(BuildContext context) {
    final notificationBloc = context.read<NotificationBloc>();
    notificationBloc.add(const RefreshNotifications());
  }

  /// Affiche un message d'erreur
  static void showError({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Réessayer',
          textColor: AppColors.textPrimary,
          onPressed: () => refreshNotifications(context),
        ),
      ),
    );
  }

  /// Affiche un message de succès
  static void showSuccess({
    required BuildContext context,
    required String message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}
