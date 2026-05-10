import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Header du Home Locataire — greeting + bell + avatar.
///
/// Reproduit le bloc top du proto : à gauche `Bonsoir, ` (text-3) et
/// `${prénom} 👋` (h2). À droite : IconBoutton bell + UserAvatar 36px.
class LocataireHomeHeader extends StatelessWidget {
  final String firstName;
  final VoidCallback? onBellTap;
  final VoidCallback? onAvatarTap;
  final String? avatarUrl;

  const LocataireHomeHeader({
    super.key,
    required this.firstName,
    this.onBellTap,
    this.onAvatarTap,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonsoir,',
                style: AppTextStyles.small.copyWith(color: AppColors.text3),
              ),
              const SizedBox(height: 2),
              Text(
                '$firstName 👋',
                style: AppTextStyles.h2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconBoutton(
          icon: Icons.notifications_outlined,
          onPressed: onBellTap,
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onAvatarTap,
          child: UserAvatar(name: firstName, imageUrl: avatarUrl),
        ),
      ],
    );
  }
}
