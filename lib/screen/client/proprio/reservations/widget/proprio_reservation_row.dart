import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/util/calc/reservation_status_display.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/img/img_placeholder.dart';

/// Ligne d'une réservation côté propriétaire — `ProprioReservationsScreen`.
///
/// Layout : ImgPh tone 44×44 + Column (nom client + statut badge / appart
/// titre · dates / éventuellement source démarcheur) + montant total à droite.
class ProprioReservationRow extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap;
  final bool isLast;

  const ProprioReservationRow({
    super.key,
    required this.reservation,
    this.onTap,
    this.isLast = false,
  });

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String _formatDates() {
    final d = reservation.debut;
    final f = reservation.fin;
    if (d == null || f == null) return '';
    final m = _months[d.month - 1];
    return '${d.day}-${f.day} $m';
  }

  String _clientName() {
    final n = reservation.clientNom?.trim();
    return n != null && n.isNotEmpty ? n : 'Client #${reservation.id ?? 0}';
  }

  @override
  Widget build(BuildContext context) {
    final appart = reservation.appart;
    final tone = appart?.tone ?? 1;
    final apartTitle = appart?.titre ?? 'Logement';
    final dates = _formatDates();
    final amount = (reservation.prix ?? 0).round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.line, width: 1),
                  ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: ImgPh(tone: tone, radius: 10),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _clientName(),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        BadgeStatus(
                          text: ReservationStatusDisplay.labelOf(
                              reservation.statut),
                          tone: ReservationStatusDisplay.toneOf(
                              reservation.statut),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dates.isEmpty ? apartTitle : '$apartTitle · $dates',
                      style: AppTextStyles.small.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                FcfaFormatter.compact(amount),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                )),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
