import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Badge compact pour afficher le statut d'une réservation
/// Réutilisable dans les listes et détails
class ReservationStatusBadgeCompact extends StatelessWidget {
  const ReservationStatusBadgeCompact({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  final ReservationStatus status;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(config.icon, size: 14, color: AppColors.white),
            SizedBox(width: 4),
          ],
          TextSeed(
            config.label,
            fontSize: 12,
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  /// Retourne la configuration (couleur, icône, label) pour un statut
  _StatusConfig _getStatusConfig(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.enAttente:
        return _StatusConfig(
          color: AppColors.warning, // Orange
          label: "En attente",
          icon: Icons.schedule,
        );
      case ReservationStatus.confirmee:
        return _StatusConfig(
          color: AppColors.success, // Vert
          label: "Confirmée",
          icon: Icons.check_circle,
        );
      case ReservationStatus.payee:
        return _StatusConfig(
          color: Color(0xFF2E7D32), // Vert foncé
          label: "Payée",
          icon: Icons.payment,
        );
      case ReservationStatus.finalisee:
        return _StatusConfig(
          color: Color(0xFF1565C0), // Bleu foncé
          label: "Finalisée",
          icon: Icons.check_circle_outline,
        );
      case ReservationStatus.refusee:
        return _StatusConfig(
          color: AppColors.error,
          label: "Refusée",
          icon: Icons.cancel,
        );
      case ReservationStatus.annulee:
        return _StatusConfig(
          color: AppColors.inactive,
          label: "Annulée",
          icon: Icons.block,
        );
      case ReservationStatus.terminee:
        return _StatusConfig(
          color: AppColors.info, // Bleu
          label: "Terminée",
          icon: Icons.done_all,
        );
    }
  }
}

/// Configuration d'affichage d'un statut
class _StatusConfig {
  final Color color;
  final String label;
  final IconData icon;

  _StatusConfig({required this.color, required this.label, required this.icon});
}
