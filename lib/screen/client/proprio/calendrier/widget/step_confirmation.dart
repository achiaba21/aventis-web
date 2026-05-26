import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/feedback/success_circle.dart';

/// Step 3 du wizard — confirmation de la réservation manuelle créée.
class StepConfirmation extends StatelessWidget {
  final Reservation reservation;
  final String clientNom;

  const StepConfirmation({
    super.key,
    required this.reservation,
    required this.clientNom,
  });

  String _dateRange() {
    final d = reservation.debut;
    final f = reservation.fin;
    if (d == null || f == null) return '—';
    final monthsShort = [
      'janv',
      'févr',
      'mars',
      'avr',
      'mai',
      'juin',
      'juil',
      'août',
      'sept',
      'oct',
      'nov',
      'déc',
    ];
    final fLast = f.subtract(const Duration(days: 1));
    final mois = monthsShort[d.month - 1];
    final nb = fLast.difference(d).inDays + 1;
    return '${d.day}-${fLast.day} $mois · ${nb}n';
  }

  @override
  Widget build(BuildContext context) {
    final ref = reservation.reference ?? '—';
    final logement = reservation.appart?.titre ?? '—';
    final total = (reservation.prix ?? 0).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        const SuccessCircle(color: AppColors.success),
        const SizedBox(height: 24),
        Text(
          'Réservation enregistrée',
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Le calendrier est mis à jour. $clientNom recevra une confirmation par SMS.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Column(
            children: [
              _RecapRow(label: 'Référence', value: ref),
              const SizedBox(height: 8),
              _RecapRow(label: 'Logement', value: logement),
              const SizedBox(height: 8),
              _RecapRow(label: 'Dates', value: _dateRange()),
              const SizedBox(height: 8),
              _RecapRow(
                label: 'Total client',
                value: FcfaFormatter.full(total),
                emphasis: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _RecapRow({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body
              .copyWith(fontSize: 13, color: AppColors.text2),
        ),
        const Spacer(),
        Text(
          value,
          textAlign: TextAlign.right,
          style: AppTextStyles.mono(TextStyle(
            fontSize: emphasis ? 15 : 13,
            fontWeight: emphasis ? FontWeight.w700 : FontWeight.w500,
            color: emphasis ? AppColors.accent : AppColors.text,
          )),
        ),
      ],
    );
  }
}
