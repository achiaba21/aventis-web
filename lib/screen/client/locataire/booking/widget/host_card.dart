import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Card hôte du Detail logement.
///
/// Avatar 48px + nom + badge "★ Certifié" si applicable + sub
/// (`Hôte depuis 2023 · répond en 1 h`) + bouton secondary "Contacter".
class HostCard extends StatelessWidget {
  final String hostName;
  final String memberSince;
  final String responseTime;
  final bool certified;
  final VoidCallback? onContactTap;

  const HostCard({
    super.key,
    required this.hostName,
    required this.memberSince,
    this.responseTime = '1 h',
    this.certified = false,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          UserAvatar(name: hostName, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        hostName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (certified) ...[
                      const SizedBox(width: 6),
                      const BadgeStatus(
                        text: '★ Certifié',
                        tone: BadgeTone.accent,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Hôte depuis $memberSince · répond en $responseTime',
                  style: AppTextStyles.small.copyWith(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onContactTap != null) ...[
            const SizedBox(width: 12),
            OutlinedCustomButton(
              text: 'Contacter',
              onPressed: onContactTap,
              size: ButtonSize.sm,
              leadingIcon: Icons.chat_bubble_outline,
            ),
          ],
        ],
      ),
    );
  }
}
