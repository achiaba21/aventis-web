import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/notification/notification.dart';
import 'package:asfar/service/notification/notification_helper.dart';
import 'package:asfar/util/string_utils.dart';
import 'package:asfar/widget/date/date_format.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bottom sheet pour afficher le détail d'une notification
class NotificationDetailSheet extends StatelessWidget {
  const NotificationDetailSheet({
    super.key,
    required this.notification,
  });

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textPrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Contenu
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    TextSeed(
                      notification.displayTitle,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),

                    SizedBox(height: Espacement.gapSection),

                    // Date
                    if (notification.createdAt != null)
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: AppColors.textPrimary.withValues(alpha: 0.7)),
                          const SizedBox(width: 6),
                          TextSeed(
                            DateFormatUtils.formatRelativeDate(notification.createdAt!),
                            fontSize: 14,
                            color: AppColors.textPrimary.withValues(alpha: 0.7),
                          ),
                        ],
                      ),

                    SizedBox(height: Espacement.paddingBloc),

                    // Contenu
                    if (notification.contenu != null) ...[
                      Container(
                        padding: EdgeInsets.all(Espacement.paddingBloc),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Espacement.radius),
                          border: Border.all(
                            color: AppColors.textPrimary.withValues(alpha: 0.1),
                          ),
                        ),
                        child: TextSeed(
                          notification.contenu!,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: Espacement.paddingBloc),
                    ],

                    // Informations de l'expéditeur
                    if (notification.user != null) ...[
                      Divider(height: Espacement.paddingBloc * 2, color: AppColors.textPrimary.withValues(alpha: 0.1)),
                      TextSeed(
                        'De',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                            child: TextSeed(
                              StringUtils.getInitials(notification.user!.nom ?? ''),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextSeed(
                                  notification.user!.nom ?? 'Utilisateur',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                if (notification.user!.telephone != null)
                                  TextSeed(
                                    notification.user!.telephone!,
                                    fontSize: 14,
                                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    SizedBox(height: Espacement.paddingBloc * 2),

                    // Boutons d'action
                    Row(
                      children: [
                        // Bouton Marquer comme lu/non lu
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              NotificationHelper.toggleReadStatus(
                                context: context,
                                notification: notification,
                              );
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              notification.isUnread ? Icons.mark_email_read : Icons.mark_email_unread,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            label: TextSeed(
                              notification.isUnread ? 'Marquer lu' : 'Marquer non lu',
                              fontSize: 14,
                              color: AppColors.accent,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: AppColors.accent),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Bouton Supprimer
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              NotificationHelper.deleteNotificationWithConfirm(
                                context: context,
                                notification: notification,
                              );
                            },
                            icon: Icon(Icons.delete, size: 18, color: AppColors.error),
                            label: TextSeed(
                              'Supprimer',
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: AppColors.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
