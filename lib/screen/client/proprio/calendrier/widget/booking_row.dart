import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Row d'une réservation dans la liste « Réservations du mois ».
///
/// Layout proto :
/// - Pastille date verticale gauche (JJ-JJ / MOIS en accentSoft)
/// - Centre : nom client + source/démarcheur + badge statut
/// - Droite : montant accent (+X k FCFA)
class BookingRow extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap;

  const BookingRow({
    super.key,
    required this.reservation,
    this.onTap,
  });

  static const _monthsShort = [
    'JANV', 'FEVR', 'MARS', 'AVR', 'MAI', 'JUIN',
    'JUIL', 'AOUT', 'SEPT', 'OCT', 'NOV', 'DEC',
  ];

  String _dateRange() {
    final d = reservation.debut;
    final f = reservation.fin;
    if (d == null || f == null) return '—';
    final fLast = f.subtract(const Duration(days: 1));
    if (d.month == fLast.month && d.year == fLast.year) {
      return '${d.day}-${fLast.day}';
    }
    return '${d.day}-${fLast.day}';
  }

  String _monthLabel() {
    final d = reservation.debut;
    if (d == null) return '';
    return _monthsShort[d.month - 1];
  }

  String _sourceLabel() {
    if (reservation.type?.name == 'demarcheur') {
      return 'Démarcheur';
    }
    if (reservation.type?.name == 'manuelle') {
      return 'Direct';
    }
    return 'Asfar';
  }

  ({String text, BadgeTone tone}) _statusBadge() {
    switch (reservation.statut) {
      case ReservationStatus.confirmee:
      case ReservationStatus.payee:
      case ReservationStatus.finalisee:
        return (text: 'Confirmé', tone: BadgeTone.success);
      case ReservationStatus.enAttente:
        return (text: 'En cours', tone: BadgeTone.warn);
      case ReservationStatus.refusee:
      case ReservationStatus.annulee:
        return (text: 'Annulé', tone: BadgeTone.danger);
      case ReservationStatus.terminee:
        return (text: 'Terminé', tone: BadgeTone.neutral);
      case null:
        return (text: '—', tone: BadgeTone.neutral);
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientNom = reservation.clientExterneNom ??
        reservation.locataire?.fullName ??
        'Client';
    final montant = (reservation.prix ?? 0).round();
    final status = _statusBadge();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Row(
            children: [
              // Date verticale (badge gauche)
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _dateRange(),
                      style: AppTextStyles.mono(const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      )),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _monthLabel(),
                      style: AppTextStyles.eyebrow.copyWith(
                        fontSize: 9,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Centre — nom, source, badge statut
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      clientNom,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _sourceLabel(),
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.text3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BadgeStatus(text: status.text, tone: status.tone),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Montant droite
              Text(
                '+${FcfaFormatter.compact(montant)}',
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
