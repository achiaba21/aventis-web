import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Toggle pour changer le mode de vue (Résidence / Appartement)
class ViewModeToggle extends StatelessWidget {
  final bool isAppartementMode;
  final Function(bool parAppartement) onModeChanged;

  const ViewModeToggle({
    super.key,
    required this.isAppartementMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: ViewModeButton(
              label: "Par résidence",
              icon: Icons.apartment,
              isSelected: !isAppartementMode,
              onTap: () => onModeChanged(false),
            ),
          ),
          Expanded(
            child: ViewModeButton(
              label: "Par appartement",
              icon: Icons.door_front_door_outlined,
              isSelected: isAppartementMode,
              onTap: () => onModeChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton individuel du toggle de mode
class ViewModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const ViewModeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.textOnAccent : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            TextSeed(
              label,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.textOnAccent : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
