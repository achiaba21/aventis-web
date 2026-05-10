import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_settings_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Une ligne du `ProfileSettingsCard` : icon + label + (optionnel) valeur
/// + arrow forward. Tap zone full-width via Material/InkWell.
class ProfileSettingsRow extends StatelessWidget {
  final ProfileSettingsItem item;
  final bool isLast;

  const ProfileSettingsRow({
    super.key,
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
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
