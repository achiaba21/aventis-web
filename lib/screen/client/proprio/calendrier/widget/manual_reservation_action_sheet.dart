import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Action retournée par le `ManualReservationActionSheet` (cf. business §4.4).
enum ManualReservationAction {
  /// Le proprio veut bloquer une période (maintenance, perso).
  block,

  /// Le proprio veut créer une réservation manuelle (client direct).
  reserve,
}

/// Bottom sheet présentant les 2 actions disponibles depuis le bouton
/// « + Bloquer / Réserver » du `CalendarBookingsScreen`.
class ManualReservationActionSheet extends StatelessWidget {
  const ManualReservationActionSheet({super.key});

  /// Helper d'ouverture. Renvoie l'action choisie ou `null` si annulé.
  static Future<ManualReservationAction?> show(BuildContext context) {
    return showModalBottomSheet<ManualReservationAction>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => const ManualReservationActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.bgElev3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _ActionTile(
              icon: Icons.lock_clock_outlined,
              title: 'Bloquer une période',
              subtitle: 'Maintenance, séjour perso, indisponible.',
              onTap: () =>
                  Navigator.of(context).pop(ManualReservationAction.block),
            ),
            const SizedBox(height: 6),
            _ActionTile(
              icon: Icons.person_add_alt_outlined,
              title: 'Réserver pour un client direct',
              subtitle: 'Client externe à Asfar (espèces, paiement direct…).',
              onTap: () =>
                  Navigator.of(context).pop(ManualReservationAction.reserve),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, size: 20, color: AppColors.accent),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.text3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
