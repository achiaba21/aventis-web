import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// En-tête de la liste des notifications avec actions
class NotificationListHeader extends StatelessWidget {
  const NotificationListHeader({
    super.key,
    required this.totalCount,
    required this.unreadCount,
    this.onMarkAllAsRead,
    this.onClearAll,
  });

  final int totalCount;
  final int unreadCount;
  final VoidCallback? onMarkAllAsRead;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Compteur de notifications
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                '$totalCount notification${totalCount > 1 ? 's' : ''}',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 4),
                TextSeed(
                  '$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
                  fontSize: 13,
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),

          // Boutons d'action
          Row(
            children: [
              // Bouton "Tout marquer comme lu"
              if (unreadCount > 0 && onMarkAllAsRead != null) ...[
                _buildActionButton(
                  icon: Icons.done_all,
                  label: 'Tout lire',
                  onPressed: onMarkAllAsRead!,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 8),
              ],

              // Menu avec options supplémentaires
              if (onClearAll != null)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.accent,
                  ),
                  onSelected: (value) {
                    if (value == 'clear_all') {
                      onClearAll?.call();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'clear_all',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, size: 20, color: AppColors.error),
                          const SizedBox(width: 12),
                          const Text('Tout effacer'),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18, color: color),
      label: TextSeed(
        label,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
