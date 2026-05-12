import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Section "Informations" : audit (créée le / mise à jour le) + notes.
///
/// Caché complètement si aucune info disponible.
class ChargeDetailMetaSection extends StatelessWidget {
  final Charge charge;

  const ChargeDetailMetaSection({super.key, required this.charge});

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String _formatShort(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final notes = charge.notes?.trim();
    final hasNotes = notes != null && notes.isNotEmpty;
    final hasAudit = charge.createdAt != null || charge.updatedAt != null;
    if (!hasNotes && !hasAudit) return const SizedBox.shrink();

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
          if (hasNotes) ...[
            Text(
              notes,
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
            if (hasAudit) const SizedBox(height: 12),
          ],
          if (hasAudit) ...[
            if (charge.createdAt != null)
              Text(
                'Créée le ${_formatShort(charge.createdAt)}',
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  color: AppColors.text3,
                ),
              ),
            if (charge.updatedAt != null) ...[
              const SizedBox(height: 2),
              Text(
                'Mise à jour le ${_formatShort(charge.updatedAt)}',
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  color: AppColors.text3,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
