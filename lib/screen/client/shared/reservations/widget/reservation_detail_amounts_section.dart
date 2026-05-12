import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Section "Montants" de la page détail réservation.
///
/// Lignes clé/val : prix total, frais Asfar (si > 0), avance versée (si > 0),
/// divider, reste à payer en or si > 0. Tous les montants en mono pour
/// alignement tabular.
class ReservationDetailAmountsSection extends StatelessWidget {
  final Reservation reservation;

  const ReservationDetailAmountsSection({
    super.key,
    required this.reservation,
  });

  int get _prix => reservation.prix?.round() ?? 0;
  int get _frais => reservation.frais?.round() ?? 0;
  int get _avance => reservation.avanceReservation?.montant?.round() ?? 0;
  int get _reste => (_prix - _avance).clamp(0, _prix);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ReservationDetailAmountRow(
            label: 'Prix total',
            value: FcfaFormatter.full(_prix),
          ),
          if (_frais > 0) ...[
            const SizedBox(height: 8),
            _ReservationDetailAmountRow(
              label: 'Frais Asfar',
              value: FcfaFormatter.full(_frais),
              valueColor: AppColors.text2,
            ),
          ],
          if (_avance > 0) ...[
            const SizedBox(height: 8),
            _ReservationDetailAmountRow(
              label: 'Avance versée',
              value: '−${FcfaFormatter.full(_avance)}',
              valueColor: AppColors.text2,
            ),
          ],
          if (_avance > 0) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.line, height: 1),
            const SizedBox(height: 12),
            _ReservationDetailAmountRow(
              label: 'Reste à payer',
              value: FcfaFormatter.full(_reste),
              valueColor: AppColors.accent,
              isStrong: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _ReservationDetailAmountRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isStrong;

  const _ReservationDetailAmountRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isStrong = false,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = isStrong
        ? const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          )
        : const TextStyle(fontSize: 14, color: AppColors.text);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isStrong ? 14 : 13,
              fontWeight: isStrong ? FontWeight.w600 : FontWeight.w400,
              color: AppColors.text2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: AppTextStyles.mono(
            baseStyle.copyWith(color: valueColor ?? AppColors.text),
          ),
        ),
      ],
    );
  }
}
