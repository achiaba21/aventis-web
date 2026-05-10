import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/user/user_avatar.dart';

/// Card client du `ReferralDetailScreen` — avatar + nom + téléphone +
/// bouton « Appeler ».
class ReferralClientCard extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback? onCall;

  const ReferralClientCard({
    super.key,
    required this.name,
    required this.phone,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = phone.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          UserAvatar(name: name, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasPhone ? phone : 'Téléphone non communiqué',
                  style: AppTextStyles.small.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedCustomButton(
            text: 'Appeler',
            onPressed: hasPhone ? onCall : null,
            size: ButtonSize.sm,
            leadingIcon: Icons.phone_outlined,
          ),
        ],
      ),
    );
  }
}
