import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_demarcheur.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_party_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/reservation_contact_resolver.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card "Démarcheur source" — visible uniquement par le propriétaire pour
/// une `ReservationDemarcheur`.
///
/// Affiche la `ReservationDetailPartyCard` du démarcheur + une ligne dédiée
/// "Commission convenue : X FCFA" en accent or pour transparence totale.
class ReservationDetailDemarcheurCard extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailDemarcheurCard({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final target = ReservationContactResolver.demarcheurTargetFor(reservation);
    if (target == null) return const SizedBox.shrink();

    final commission = reservation is ReservationDemarcheur
        ? ((reservation as ReservationDemarcheur).montantCommission ?? 0)
            .round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReservationDetailPartyCard(target: target),
        if (commission > 0) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              border: Border.all(
                color: AppColors.accent.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppRadii.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.handshake_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Commission convenue',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 13,
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  FcfaFormatter.full(commission),
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  )),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
