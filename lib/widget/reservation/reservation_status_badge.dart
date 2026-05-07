import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class ReservationStatusBadge extends StatelessWidget {
  const ReservationStatusBadge({super.key, required this.status});

  final ReservationStatus? status;

  /// Retourne la couleur selon le statut
  Color _getStatusColor() {
    switch (status) {
      case ReservationStatus.confirmee:
        return AppColors.success;
      case ReservationStatus.payee:
        return AppColors.success; // Vert foncé pour payée
      case ReservationStatus.finalisee:
        return AppColors.info; // Bleu foncé pour finalisée
      case ReservationStatus.enAttente:
        return AppColors.accent;
      case ReservationStatus.terminee:
        return AppColors.info;
      case ReservationStatus.refusee:
        return AppColors.error;
      case ReservationStatus.annulee:
        return AppColors.textMuted;
      default:
        return AppColors.inactive;
    }
  }

  /// Retourne le texte lisible du statut
  String _getStatusText() {
    switch (status) {
      case ReservationStatus.confirmee:
        return "Confirmée";
      case ReservationStatus.payee:
        return "Payée";
      case ReservationStatus.finalisee:
        return "Finalisée";
      case ReservationStatus.enAttente:
        return "En attente";
      case ReservationStatus.terminee:
        return "Terminée";
      case ReservationStatus.refusee:
        return "Refusée";
      case ReservationStatus.annulee:
        return "Annulée";
      default:
        return "Statut inconnu";
    }
  }

  /// Retourne l'icône selon le statut
  IconData _getStatusIcon() {
    switch (status) {
      case ReservationStatus.confirmee:
        return Icons.check_circle;
      case ReservationStatus.payee:
        return Icons.payment;
      case ReservationStatus.finalisee:
        return Icons.check_circle_outline;
      case ReservationStatus.enAttente:
        return Icons.pending;
      case ReservationStatus.terminee:
        return Icons.task_alt;
      case ReservationStatus.refusee:
        return Icons.cancel;
      case ReservationStatus.annulee:
        return Icons.block;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingBloc,
        vertical: Espacement.paddingInput,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Espacement.radius),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), color: color, size: 20),
          SizedBox(width: Espacement.paddingInput),
          TextSeed(
            _getStatusText(),
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}
