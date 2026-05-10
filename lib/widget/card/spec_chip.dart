import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Petit indicateur icon + label utilisé dans les cards de listing
/// (`5 ch.`, `2 sdb.`, `WiFi`, `38 m²`).
///
/// Icon + label en `text3` 12px.
class SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const SpecChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.text3),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.text3),
        ),
      ],
    );
  }
}
