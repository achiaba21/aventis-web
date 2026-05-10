import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/badge/badge_status.dart';
import 'package:asfar/widget/badge/badge_tone.dart';

/// Sélecteur de vue du Profil — card avec listrows par vue accessible.
///
/// V8.5 : un utilisateur n'a PAS plusieurs rôles. Mais un proprio/démarcheur
/// peut basculer en mode Locataire pour séjourner ailleurs sans changer son
/// type de compte. Ce switcher affiche uniquement les vues accessibles à
/// l'utilisateur via [availableViews] (cf. `RoleHomeRouter.availableViewsFor`).
///
/// Si une seule vue est accessible (locataire pur), le switcher peut être
/// caché par le parent — voir `ClientProfileScreen`.
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
    _RoleInfo(id: 'locataire', icon: Icons.vpn_key_outlined, label: 'Locataire'),
    _RoleInfo(id: 'proprietaire', icon: Icons.home_outlined, label: 'Propriétaire'),
    _RoleInfo(id: 'demarcheur', icon: Icons.handshake_outlined, label: 'Démarcheur'),
  ];

  List<_RoleInfo> get _visibleRoles {
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
            _row(context, roles[i], isLast: i == roles.length - 1),
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
