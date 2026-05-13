import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Section "Dates" du `ChargeDetailScreen` : clé/val pour début, échéance,
/// paiement.
class ChargeDetailDatesSection extends StatelessWidget {
  final Charge charge;

  const ChargeDetailDatesSection({super.key, required this.charge});

  static const _months = [
    'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
    'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre',
  ];

  String _formatLong(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

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
        mainAxisSize: MainAxisSize.min,
        children: [
          _DateRow(label: 'Paiement', value: _formatLong(charge.dateDebut)),
          if (charge.estRecurrent == true && charge.dateEcheance != null) ...[
            const SizedBox(height: 10),
            _DateRow(
              label: 'Prochaine échéance',
              value: _formatLong(charge.dateEcheance),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final String value;

  const _DateRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.small.copyWith(
              fontSize: 13,
              color: AppColors.text2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: AppTextStyles.mono(const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AppColors.text,
          )),
        ),
      ],
    );
  }
}
