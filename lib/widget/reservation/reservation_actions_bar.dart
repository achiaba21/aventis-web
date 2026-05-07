import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bottom bar avec actions conditionnelles pour le propriétaire
class ReservationActionsBar extends StatelessWidget {
  const ReservationActionsBar({
    super.key,
    required this.reservation,
    this.onAccept,
    this.onRefuse,
    this.onCancel,
    this.onScanQR,
  });

  final Reservation reservation;
  final VoidCallback? onAccept;
  final VoidCallback? onRefuse;
  final VoidCallback? onCancel;
  final VoidCallback? onScanQR;

  @override
  Widget build(BuildContext context) {
    final status = reservation.statut ?? ReservationStatus.enAttente;

    // Si la réservation est en attente, afficher les boutons Accepter/Refuser
    if (status == ReservationStatus.enAttente) {
      return Container(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          spacing: Espacement.gapSection,
          children: [
            Expanded(
              child: PlainButton(
                value: "Refuser",
                plain: false,
                color: AppColors.error,
                onPress: onRefuse ?? () {},
              ),
            ),
            Expanded(
              child: PlainButton(
                value: "Accepter",
                plain: false,
                color: AppColors.success,
                onPress: onAccept ?? () {},
              ),
            ),
          ],
        ),
      );
    }

    // Si la réservation est confirmée, afficher Scanner QR et Annuler
    if (status == ReservationStatus.confirmee) {
      return Container(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          spacing: Espacement.gapSection,
          children: [
            Expanded(
              child: PlainButton(
                value: "Annuler",
                plain: false,
                color: AppColors.error,
                onPress: onCancel ?? () {},
              ),
            ),
            if (false)
              Expanded(
                flex: 2,
                child: PlainButton(
                  value: "Scanner QR Code",
                  plain: false,
                  color: AppColors.success,
                  onPress: onScanQR ?? () {},
                ),
              ),
          ],
        ),
      );
    }

    // Pour les autres statuts, ne rien afficher ou juste un bouton retour
    return SizedBox.shrink();
  }
}
