import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Card de calcul de commission — `ReferralDetailScreen`.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurReferralDetail` :
/// sous-total séjour → 10% → "À recevoir" en accent or.
///
/// Le commission s'affiche en mono bold accent or, séparée par un divider
/// `line` du sous-total.
class CommissionCard extends StatelessWidget {
  final int subtotal;
  final int commission;
  final double rate;

  const CommissionCard({
    super.key,
    required this.subtotal,
    required this.commission,
    this.rate = 0.10,
  });

  @override
  Widget build(BuildContext context) {
    final ratePercent = (rate * 100).round();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(
            label: 'Sous-total séjour',
            value: FcfaFormatter.full(subtotal),
            valueColor: AppColors.text,
            mono: true,
          ),
          const SizedBox(height: 10),
          _line(
            label: 'Commission démarcheur',
            value: '$ratePercent %',
            valueColor: AppColors.text2,
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.line, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'À recevoir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                FcfaFormatter.full(commission),
                style: AppTextStyles.mono(const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line({
    required String label,
    required String value,
    required Color valueColor,
    bool mono = false,
  }) {
    final base = TextStyle(fontSize: 13, color: valueColor);
    final style = mono
        ? AppTextStyles.mono(base.copyWith(fontWeight: FontWeight.w600))
        : base.copyWith(fontWeight: FontWeight.w500);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.small),
        Text(value, style: style),
      ],
    );
  }
}
