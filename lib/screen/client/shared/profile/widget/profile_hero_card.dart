import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Hero card du Profil — avatar 78 + nom + shield + sub + badge optionnel.
///
/// Composant transverse partagé par les Shells locataire/démarcheur/proprio
/// (cf. `extras.jsx::Profile` du prototype, ligne 303-313).
class ProfileHeroCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool verified;
  final String? badge;
  final String? avatarUrl;

  const ProfileHeroCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.verified = false,
    this.badge,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        children: [
          UserAvatar(name: name, size: 78, imageUrl: avatarUrl),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (verified) ...[
                const SizedBox(width: 6),
                const Icon(Icons.verified,
                    size: 14, color: AppColors.accent),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.small,
            textAlign: TextAlign.center,
          ),
          if (badge != null) ...[
            const SizedBox(height: 12),
            BadgeStatus(text: badge!, tone: BadgeTone.accent),
          ],
        ],
      ),
    );
  }
}
