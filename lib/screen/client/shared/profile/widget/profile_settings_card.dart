import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card de paramètres du Profil — listrows icon + label + valeur + arrow.
///
/// Composant transverse partagé par les Shells locataire/démarcheur/proprio
/// (cf. `extras.jsx::Profile` du prototype, lignes 343-359).
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
            _row(items[i], isLast: i == items.length - 1),
        ],
      ),
    );
  }

  Widget _row(ProfileSettingsItem item, {required bool isLast}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                    bottom: BorderSide(color: AppColors.line, width: 1),
                  ),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: AppColors.text2),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: const TextStyle(fontSize: 14, color: AppColors.text),
                ),
              ),
              if (item.value != null) ...[
                Text(item.value!,
                    style: AppTextStyles.small.copyWith(fontSize: 12)),
                const SizedBox(width: 8),
              ],
              const Icon(Icons.arrow_forward_ios,
                  size: 14, color: AppColors.text3),
            ],
          ),
        ),
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
