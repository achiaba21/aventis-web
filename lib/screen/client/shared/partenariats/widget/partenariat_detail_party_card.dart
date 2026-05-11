import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Card affichant une partie (démarcheur OU proprio) du
/// `PartenariatDetailScreen` — V9.2.
///
/// Avatar gradient or 48×48 avec initiales `onAccent` + Column [eyebrow
/// rôle + nom h3 + téléphone mono text3] + IconBoutton phone accent or
/// (disabled si téléphone vide).
class PartenariatDetailPartyCard extends StatelessWidget {
  final String role;
  final String nom;
  final String telephone;

  const PartenariatDetailPartyCard({
    super.key,
    required this.role,
    required this.nom,
    required this.telephone,
  });

  String get _initial {
    final trimmed = nom.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  bool get _hasPhone => telephone.trim().isNotEmpty;

  Future<void> _onCall(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final uri = Uri(scheme: 'tel', path: telephone.trim());
      final ok = await launchUrl(uri);
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Impossible de lancer l\'appel'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      deboger('PartenariatDetailPartyCard._onCall: $e');
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Impossible de lancer l\'appel'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PartyAvatar(initial: _initial),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(role.toUpperCase(), style: AppTextStyles.eyebrow),
                const SizedBox(height: 4),
                Text(
                  nom.trim().isNotEmpty ? nom : '—',
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _hasPhone ? telephone : 'Téléphone non renseigné',
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
          const SizedBox(width: 8),
          Opacity(
            opacity: _hasPhone ? 1.0 : 0.4,
            child: IconBoutton(
              icon: Icons.phone_outlined,
              onPressed: _hasPhone ? () => _onCall(context) : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyAvatar extends StatelessWidget {
  final String initial;

  const _PartyAvatar({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.avatarGradientStart,
            AppColors.avatarGradientEnd,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.onAccent,
          ),
        ),
      ),
    );
  }
}
