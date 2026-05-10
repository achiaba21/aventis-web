import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_settings_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Card de paramètres du Profil — listrows icon + label + valeur + arrow.
class ProfileSettingsCard extends StatelessWidget {
  final List<ProfileSettingsItem> items;

  const ProfileSettingsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            ProfileSettingsRow(
              item: items[i],
              isLast: i == items.length - 1,
            ),
        ],
      ),
    );
  }
}

/// Une ligne du [ProfileSettingsCard].
class ProfileSettingsItem {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;

  const ProfileSettingsItem({
    required this.icon,
    required this.label,
    this.value,
    this.onTap,
  });
}
