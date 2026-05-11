import 'package:flutter/material.dart';
import 'package:asfar/model/partenariat/statut_partenariat.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Section "Statut" du `PartenariatDetailScreen` — V9.2.
///
/// Container `bgElev1` + border `line` qui présente : eyebrow STATUT +
/// chip statut large (success/warn/danger selon `StatutPartenariat`) +
/// sub-line dates "Envoyée le X · Répondue le Y" (Y optionnel).
class PartenariatDetailStatusSection extends StatelessWidget {
  final StatutPartenariat statut;
  final DateTime createdAt;
  final DateTime? repondueAt;

  const PartenariatDetailStatusSection({
    super.key,
    required this.statut,
    required this.createdAt,
    this.repondueAt,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  String _dateLine() {
    final sent = 'Envoyée le ${_formatDate(createdAt)}';
    if (repondueAt == null) return sent;
    return '$sent · Répondue le ${_formatDate(repondueAt!)}';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('STATUT', style: AppTextStyles.eyebrow),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatutChip(statut: statut),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _dateLine(),
            style: AppTextStyles.small.copyWith(
              fontSize: 12,
              color: AppColors.text2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatutChip extends StatelessWidget {
  final StatutPartenariat statut;

  const _StatutChip({required this.statut});

  ({Color bg, Color fg, IconData icon, String label}) _theme() {
    switch (statut) {
      case StatutPartenariat.acceptee:
        return (
          bg: AppColors.success.withValues(alpha: 0.14),
          fg: AppColors.success,
          icon: Icons.check_circle_outline,
          label: 'Acceptée',
        );
      case StatutPartenariat.refusee:
        return (
          bg: AppColors.danger.withValues(alpha: 0.14),
          fg: AppColors.danger,
          icon: Icons.cancel_outlined,
          label: 'Refusée',
        );
      case StatutPartenariat.enAttente:
        return (
          bg: AppColors.warn.withValues(alpha: 0.14),
          fg: AppColors.warn,
          icon: Icons.schedule_outlined,
          label: 'En attente',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _theme();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: t.bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(t.icon, size: 14, color: t.fg),
          const SizedBox(width: 6),
          Text(
            t.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: t.fg,
            ),
          ),
        ],
      ),
    );
  }
}
