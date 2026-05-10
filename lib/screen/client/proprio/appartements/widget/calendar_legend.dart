import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Légende des couleurs du `MiniCalendarGrid` — 3 entrées du proto.
///
/// Reproduit le proto `proprietaire.jsx::CalendarView` (lignes 627-642) :
/// 3 entrées seulement (Réservé / En attente / Aujourd'hui) — PAS « Disponible ».
class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: const [
          _LegendEntry(
            label: 'Réservé',
            color: AppColors.accent,
          ),
          _LegendEntry(
            label: 'En attente',
            color: AppColors.accentSoft,
            borderColor: Color(0x66E8B86B),
          ),
          _LegendEntry(
            label: "Aujourd'hui",
            color: Colors.transparent,
            borderColor: AppColors.accent,
            borderWidth: 1.5,
          ),
        ],
      ),
    );
  }
}

class _LegendEntry extends StatelessWidget {
  final String label;
  final Color color;
  final Color? borderColor;
  final double borderWidth;

  const _LegendEntry({
    required this.label,
    required this.color,
    this.borderColor,
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: borderWidth)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.text2),
        ),
      ],
    );
  }
}
