import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Toggle Asfar custom — 44×26 pill, accent quand on, bgElev3 quand off,
/// bullet blanc 22×22 qui translate avec animation 200ms.
///
/// Reproduit `proprietaire-extras.jsx::Toggle` (lignes 474-488).
class AsfarToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AsfarToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 44,
        height: 26,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.accent : AppColors.bgElev3,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
