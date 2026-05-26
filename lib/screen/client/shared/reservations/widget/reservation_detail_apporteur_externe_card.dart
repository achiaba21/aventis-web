import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card « Apporteur d'affaires (hors plateforme) » — visible uniquement par
/// le propriétaire pour une `ReservationManuelle` qui a un apporteur externe
/// renseigné (nom non vide).
///
/// Affiche le nom + téléphone (s'il y en a un) + la commission convenue. Pas
/// de bouton « Contacter » in-app car l'apporteur n'a pas de compte Asfar :
/// le proprio le contacte par ses propres moyens (téléphone direct).
class ReservationDetailApporteurExterneCard extends StatelessWidget {
  final ReservationManuelle reservation;

  const ReservationDetailApporteurExterneCard({
    super.key,
    required this.reservation,
  });

  @override
  Widget build(BuildContext context) {
    final nom = reservation.demarcheurNomExterne ?? '';
    if (nom.trim().isEmpty) return const SizedBox.shrink();
    final tel = reservation.demarcheurTelephoneExterne ?? '';
    final commission = (reservation.montantCommission ?? 0).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  nom.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (tel.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tel,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 13,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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
                    'Commission due',
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
