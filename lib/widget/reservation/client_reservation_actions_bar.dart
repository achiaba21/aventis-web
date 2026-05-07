import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/locataire/home/appart_detail_screen.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/theme/app_colors.dart';

/// Bottom bar avec actions conditionnelles pour le client/locataire
class ClientReservationActionsBar extends StatelessWidget {
  const ClientReservationActionsBar({
    super.key,
    required this.reservation,
    this.onPay,
  });

  final Reservation reservation;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final status = reservation.statut ?? ReservationStatus.enAttente;

    // Si la réservation est confirmée (et pas encore payée), afficher le bouton Payer
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
        child: PlainButton(
          value: "Payer la réservation",
          plain: false,
          color: AppColors.success,
          onPress: onPay ?? () {},
        ),
      );
    }

    // Si la réservation est terminée et l'appartement existe, afficher le bouton Re-réserver
    if (status == ReservationStatus.terminee && reservation.appart != null) {
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
        child: PlainButton(
          value: "Réserver à nouveau",
          plain: false,
          color: AppColors.accent,
          onPress: () {
            pushScreen(
              context,
              AppartDetailScreen(reservation.appart!),
            );
          },
        ),
      );
    }

    // Pour les autres statuts (EN_ATTENTE, PAYEE, FINALISEE, REFUSEE, ANNULEE),
    // ne rien afficher
    return SizedBox.shrink();
  }
}
