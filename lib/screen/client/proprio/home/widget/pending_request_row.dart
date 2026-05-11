import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/reservation_type.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/user/user_avatar.dart';

const _kMonths = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
];

/// Extension de présentation pour la section « Demandes en attente » du
/// Dashboard proprio — usage UI uniquement.
extension PendingDisplay on Reservation {
  String get pendingWhoLabel {
    final base = clientNom?.trim().isNotEmpty == true
        ? clientNom!
        : 'Client #${id ?? 0}';
    if (type == ReservationType.demarcheur) return '$base (démarcheur)';
    return 'Direct: $base';
  }

  String get pendingTypeLabel {
    if (type == ReservationType.demarcheur) return 'Réservation pour client';
    return 'Demande de réservation';
  }

  String get pendingContextLabel {
    final apartTitle = appart?.titre ?? 'Logement';
    final d = debut;
    final f = fin;
    if (d == null || f == null) return apartTitle;
    final m = _kMonths[d.month - 1];
    final nights = f.difference(d).inDays;
    final datesPart = '${d.day}-${f.day} $m · $nights nuit${nights > 1 ? 's' : ''}';
    return '$apartTitle · $datesPart';
  }

  bool get isPendingNew => statut == ReservationStatus.enAttente;
}

/// Ligne d'une demande en attente — Dashboard propriétaire.
///
/// Consomme directement le modèle métier [Reservation]. Reproduit le proto
/// `proprietaire.jsx::ProprietaireDashboard` (lignes 152-170) : avatar 36×36
/// (initiales) + nom + badge « NOUVEAU » (accent or) si applicable + type +
/// contexte + chevron.
class PendingRequestRow extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback? onTap;
  final bool isLast;

  const PendingRequestRow({
    super.key,
    required this.reservation,
    this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserAvatar(name: reservation.pendingWhoLabel, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            reservation.pendingWhoLabel,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (reservation.isPendingNew) ...[
                          const SizedBox(width: 6),
                          const BadgeStatus(
                            text: 'NOUVEAU',
                            tone: BadgeTone.accent,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reservation.pendingTypeLabel,
                      style: AppTextStyles.small.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reservation.pendingContextLabel,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.text3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
