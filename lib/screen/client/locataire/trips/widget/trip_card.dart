import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/img/domain_image.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

const _kMonths = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

/// Extension de présentation pour `Reservation` — usage UI uniquement.
extension TripDisplay on Reservation {
  bool get isUpcomingTrip {
    final s = statut;
    if (s == ReservationStatus.annulee ||
        s == ReservationStatus.finalisee) {
      return false;
    }
    if (debut == null) return false;
    return debut!.isAfter(DateTime.now()) ||
        s == ReservationStatus.enAttente ||
        s == ReservationStatus.confirmee ||
        s == ReservationStatus.payee;
  }

  String get tripStatusLabel {
    switch (statut) {
      case ReservationStatus.enAttente:
        return 'En attente';
      case ReservationStatus.confirmee:
        return 'Confirmée';
      case ReservationStatus.payee:
        return 'Payée';
      case ReservationStatus.finalisee:
        return 'Terminée';
      case ReservationStatus.annulee:
        return 'Annulée';
      case null:
        return '—';
    }
  }

  String get tripDatesLabel {
    final d = debut;
    final f = fin;
    if (d == null || f == null) return '—';
    final d1 = d.day;
    final d2 = f.day;
    final m1 = _kMonths[d.month - 1];
    final m2 = _kMonths[f.month - 1];
    if (d.month == f.month && d.year == f.year) return '$d1 - $d2 $m1';
    return '$d1 $m1 - $d2 $m2';
  }

  String get tripCodeLabel {
    return codeReservation?.secretKey ?? reference ?? 'RES-${id ?? 0}';
  }
}

/// Card horizontale de réservation (à venir / passée) dans `Trips`.
///
/// Consomme directement le modèle métier [Reservation]. Image 110×110
/// gauche (gradient tonal depuis l'id de l'appart) + content droite
/// (badge statut, titre, dates, code mono). Footer 3 boutons ghost si la
/// réservation est à venir.
class TripCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap;
  final VoidCallback? onContactHost;
  final VoidCallback? onItinerary;
  final VoidCallback? onReceipt;

  const TripCard({
    super.key,
    required this.reservation,
    this.onTap,
    this.onContactHost,
    this.onItinerary,
    this.onReceipt,
  });

  int get _tone => ((reservation.appart?.id ?? 0) % 4) + 1;

  String get _title => reservation.appart?.titre ?? 'Logement supprimé';

  @override
  Widget build(BuildContext context) {
    final upcoming = reservation.isUpcomingTrip;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 110,
                      height: 110,
                      child: DomainImage(
                        path: reservation.appart?.firstPhotoPath,
                        placeholder: ImgPh(tone: _tone, radius: 0),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BadgeStatus(
                              text: reservation.tripStatusLabel,
                              tone: upcoming
                                  ? BadgeTone.success
                                  : BadgeTone.neutral,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reservation.tripDatesLabel,
                              style: AppTextStyles.small.copyWith(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              reservation.tripCodeLabel,
                              style: AppTextStyles.mono(
                                AppTextStyles.small.copyWith(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (upcoming)
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.line, width: 1),
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: PlainButton(
                          text: 'Hôte',
                          onPressed: onContactHost,
                          size: ButtonSize.sm,
                          leadingIcon: Icons.chat_bubble_outline,
                          textColor: AppColors.text,
                        ),
                      ),
                      Expanded(
                        child: PlainButton(
                          text: 'Itinéraire',
                          onPressed: onItinerary,
                          size: ButtonSize.sm,
                          leadingIcon: Icons.map_outlined,
                          textColor: AppColors.text,
                        ),
                      ),
                      Expanded(
                        child: PlainButton(
                          text: 'Reçu',
                          onPressed: onReceipt,
                          size: ButtonSize.sm,
                          leadingIcon: Icons.description_outlined,
                          textColor: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
