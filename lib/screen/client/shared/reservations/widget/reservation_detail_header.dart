import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/reservation_status_display.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';

/// Hero gradient or de la page détail réservation.
///
/// Reproduit le style `heroGradientGold` du `RevenueHeroCard` proprio :
/// eyebrow référence + chip type à droite, montant en mono h1, badge statut
/// + sub-line dates+nuits.
class ReservationDetailHeader extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailHeader({super.key, required this.reservation});

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String _formatPeriod() {
    final d = reservation.debut;
    final f = reservation.fin;
    if (d == null || f == null) return '';
    final monthD = _months[d.month - 1];
    final monthF = _months[f.month - 1];
    if (d.month == f.month && d.year == f.year) {
      return '${d.day}-${f.day} $monthD ${d.year}';
    }
    return '${d.day} $monthD - ${f.day} $monthF ${f.year}';
  }

  int _nights() {
    final d = reservation.debut;
    final f = reservation.fin;
    if (d == null || f == null) return 0;
    final n = f.difference(d).inDays;
    return n > 0 ? n : 0;
  }

  String _typeLabel() {
    final t = reservation.type;
    if (t == null) return '';
    return '${t.icon} ${t.label}';
  }

  @override
  Widget build(BuildContext context) {
    final ref = reservation.reference ?? '—';
    final prix = reservation.prix?.round() ?? 0;
    final nights = _nights();
    final period = _formatPeriod();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.heroGradientGold,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'RÉSERVATION · $ref',
                  style: AppTextStyles.eyebrow.copyWith(
                    color: AppColors.accent,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                _typeLabel(),
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  color: AppColors.text2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            FcfaFormatter.full(prix),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: AppColors.text,
            )),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              BadgeStatus(
                text: ReservationStatusDisplay.labelOf(reservation.statut),
                tone: ReservationStatusDisplay.toneOf(reservation.statut),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  nights > 0 ? '· $nights nuits · $period' : '· $period',
                  style: AppTextStyles.small.copyWith(
                    fontSize: 12,
                    color: AppColors.text2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
