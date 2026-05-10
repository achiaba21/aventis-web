import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_role_switcher.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Une ligne du `ProfileRoleSwitcher` : icône colorée selon état actif +
/// label + badge "Actif" ou arrow forward.
class ProfileRoleRow extends StatelessWidget {
  final ProfileRoleInfo role;
  final bool active;
  final bool isLast;
  final VoidCallback? onTap;

  const ProfileRoleRow({
    super.key,
    required this.role,
    required this.active,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.bgElev3,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  role.icon,
                  size: 18,
                  color: active ? AppColors.onAccent : AppColors.text2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  role.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
              if (active)
                const BadgeStatus(text: 'Actif', tone: BadgeTone.accent)
              else
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
