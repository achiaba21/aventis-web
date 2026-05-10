import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Un segment du `PeriodSwitcher` (tap zone + style actif/inactif).
class PeriodSwitcherSegment extends StatelessWidget {
  final String option;
  final bool active;
  final VoidCallback onTap;

  const PeriodSwitcherSegment({
    super.key,
    required this.option,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.bgElev3 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            option,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? AppColors.text : AppColors.text3,
            ),
          ),
        ),
      ),
    );
  }
}
