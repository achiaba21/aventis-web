import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/reservation_contact_resolver.dart';

/// Card "Partie" (locataire, propriétaire, client externe ou démarcheur) de la
/// page détail réservation.
///
/// Avatar gradient or 48×48 avec initiale + Column [eyebrow rôle + nom h3 +
/// téléphone mono small]. Le contact est centralisé via l'action bar
/// "Contacter" → `ReservationContactSheet` (appel + chat).
class ReservationDetailPartyCard extends StatelessWidget {
  final ContactTarget target;

  const ReservationDetailPartyCard({super.key, required this.target});

  String get _initial {
    final trimmed = target.displayName.trim();
    if (trimmed.isEmpty || trimmed == '—') return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = target.hasPhone;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        border: Border.all(color: AppColors.line, width: 1),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ReservationPartyAvatar(initial: _initial),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  target.roleLabel.toUpperCase(),
                  style: AppTextStyles.eyebrow,
                ),
                const SizedBox(height: 4),
                Text(
                  target.displayName,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  hasPhone
                      ? target.telephone!
                      : 'Téléphone non renseigné',
                  style: AppTextStyles.mono(AppTextStyles.small.copyWith(
                    fontSize: 12,
                    color: AppColors.text3,
                  )),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationPartyAvatar extends StatelessWidget {
  final String initial;

  const _ReservationPartyAvatar({required this.initial});


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.avatarGradientStart,
            AppColors.avatarGradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.onAccent,
        ),
      ),
    );
  }
}
