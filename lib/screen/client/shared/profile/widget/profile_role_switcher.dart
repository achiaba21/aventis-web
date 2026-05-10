import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Sélecteur de rôle du Profil — card avec 3 listrows
/// (Locataire / Propriétaire / Démarcheur).
///
/// Composant transverse partagé par les Shells locataire/démarcheur/proprio
/// (cf. `extras.jsx::Profile` du prototype, lignes 318-340).
///
/// Le rôle actif a un badge "Actif" + icon en accent or, les autres ont
/// icon en `bgElev3` et arrow.
class ProfileRoleSwitcher extends StatelessWidget {
  final String currentRole;
  final ValueChanged<String>? onSwitchRole;

  const ProfileRoleSwitcher({
    super.key,
    required this.currentRole,
    this.onSwitchRole,
  });

  static const _roles = [
    _RoleInfo(id: 'locataire', icon: Icons.vpn_key_outlined, label: 'Locataire'),
    _RoleInfo(id: 'proprietaire', icon: Icons.home_outlined, label: 'Propriétaire'),
    _RoleInfo(id: 'demarcheur', icon: Icons.handshake_outlined, label: 'Démarcheur'),
  ];

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
          for (var i = 0; i < _roles.length; i++)
            _row(context, _roles[i], isLast: i == _roles.length - 1),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, _RoleInfo r, {required bool isLast}) {
    final active = currentRole == r.id;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSwitchRole?.call(r.id),
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
                  r.icon,
                  size: 18,
                  color: active ? AppColors.onAccent : AppColors.text2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  r.label,
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

class _RoleInfo {
  final String id;
  final IconData icon;
  final String label;
  const _RoleInfo(
      {required this.id, required this.icon, required this.label});
}
