import 'package:flutter/material.dart';
import 'package:asfar/screen/client/shared/profile/widget/profile_role_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Sélecteur de vue du Profil — card avec listrows par vue accessible.
class ProfileRoleSwitcher extends StatelessWidget {
  final String currentRole;
  final List<String> availableViews;
  final ValueChanged<String>? onSwitchRole;

  const ProfileRoleSwitcher({
    super.key,
    required this.currentRole,
    required this.availableViews,
    this.onSwitchRole,
  });

  static const _allRoles = [
    ProfileRoleInfo(
        id: 'locataire', icon: Icons.vpn_key_outlined, label: 'Locataire'),
    ProfileRoleInfo(
        id: 'proprietaire',
        icon: Icons.home_outlined,
        label: 'Propriétaire'),
    ProfileRoleInfo(
        id: 'demarcheur',
        icon: Icons.handshake_outlined,
        label: 'Démarcheur'),
  ];

  List<ProfileRoleInfo> get _visibleRoles {
    return _allRoles.where((r) => availableViews.contains(r.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final roles = _visibleRoles;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < roles.length; i++)
            ProfileRoleRow(
              role: roles[i],
              active: currentRole == roles[i].id,
              isLast: i == roles.length - 1,
              onTap: () => onSwitchRole?.call(roles[i].id),
            ),
        ],
      ),
    );
  }
}

/// Métadonnées d'une vue affichée par le [ProfileRoleSwitcher].
class ProfileRoleInfo {
  final String id;
  final IconData icon;
  final String label;

  const ProfileRoleInfo({
    required this.id,
    required this.icon,
    required this.label,
  });
}
