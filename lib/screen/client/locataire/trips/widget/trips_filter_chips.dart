import 'package:flutter/material.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Row 2 chips « À venir / Passés » du `LocataireTripsScreen`.
class TripsFilterChips extends StatelessWidget {
  final int upcomingCount;
  final int pastCount;
  final bool upcoming;
  final ValueChanged<bool> onUpcomingChanged;

  const TripsFilterChips({
    super.key,
    required this.upcomingCount,
    required this.pastCount,
    required this.upcoming,
    required this.onUpcomingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AsfarChip(
          label: 'À venir ($upcomingCount)',
          active: upcoming,
          onTap: () => onUpcomingChanged(true),
        ),
        const SizedBox(width: 8),
        AsfarChip(
          label: 'Passés ($pastCount)',
          active: !upcoming,
          onTap: () => onUpcomingChanged(false),
        ),
      ],
    );
  }
}
