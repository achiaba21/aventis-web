import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/calendar_stat_cell.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Row 3 colonnes des stats mensuelles dans `CalendarBookingsScreen`.
///
/// - Occupé (jours) → tone danger
/// - Libre (jours)  → tone success
/// - Manque à gagner (FCFA) → tone accent
class CalendarStatsRow extends StatelessWidget {
  final int joursOccupes;
  final int joursLibres;
  final int manqueAGagnerFcfa;

  const CalendarStatsRow({
    super.key,
    required this.joursOccupes,
    required this.joursLibres,
    required this.manqueAGagnerFcfa,
  });

  @override
  Widget build(BuildContext context) {
    // Pas de `crossAxisAlignment: stretch` ici : dans un parent loose en
    // hauteur (ListView, NestedScrollView), stretch demande Infinity.h aux
    // enfants → BoxConstraints assertion. Les 3 cells ont la même structure
    // (eyebrow + 1 ligne) donc même hauteur intrinsèque naturellement.
    return Row(
      children: [
        Expanded(
          child: CalendarStatCell(
            label: 'Occupé',
            value: '${joursOccupes}j',
            tone: AppColors.danger,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CalendarStatCell(
            label: 'Libre',
            value: '${joursLibres}j',
            tone: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CalendarStatCell(
            label: 'Manque à gagner',
            value: FcfaFormatter.compact(manqueAGagnerFcfa),
            tone: AppColors.accent,
          ),
        ),
      ],
    );
  }
}
