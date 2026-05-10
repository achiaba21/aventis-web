import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Chip filtre du design system Asfar Premium.
///
/// Reproduit `.chip` / `.chip-active` du prototype : pill rounded 999.
/// Inactif : fond `bgElev2` / texte `text2`. Actif : fond `accentSoft` /
/// border `accent×0.3` / texte `accent`.
class AsfarChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final IconData? leadingIcon;

  const AsfarChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.accent : AppColors.text2;
    final children = <Widget>[];
    if (leadingIcon != null) {
      children.add(Icon(leadingIcon, size: 14, color: fg));
      children.add(const SizedBox(width: 6));
    }
    children.add(Text(
      label,
      style: TextStyle(
        color: fg,
        fontSize: 13,
        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
      ),
    ));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.accentSoft : AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: active
                  ? const Color(0x4DE8B86B)
                  : AppColors.line,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}
