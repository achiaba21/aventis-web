import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget pour un chip de filtre de notification
class NotificationFilterChip extends StatelessWidget {
  const NotificationFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected
        ? AppColors.textPrimary
        : AppColors.textPrimary.withValues(alpha: 0.7);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Espacement.radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.white.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 6),
          TextSeed(
            label,
            color: textColor,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.textPrimary.withValues(alpha: 0.3)
                    : AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextSeed(
                count.toString(),
                color: AppColors.textPrimary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.background,
        selectedColor: AppColors.background,
        checkmarkColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Espacement.radius),
          side: BorderSide(
            color: isSelected
                ? AppColors.accent
                : AppColors.textPrimary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
