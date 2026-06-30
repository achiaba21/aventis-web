import 'package:flutter/material.dart';
import 'package:asfar/util/calc/reservation_segment.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Row horizontale de chips « par intention » (À traiter / À venir /
/// Historique) avec compteur par segment.
///
/// Remplace l'ancien `ReservationsFilterChipsRow` (statuts bruts) sur
/// `ProprioReservationsScreen`.
class ReservationsSegmentChipsRow extends StatelessWidget {
  final ReservationSegment selected;
  final Map<ReservationSegment, int> counts;
  final ValueChanged<ReservationSegment> onSelect;

  const ReservationsSegmentChipsRow({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final segments = ReservationSegment.values;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: segments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final segment = segments[i];
          final count = counts[segment] ?? 0;
          final label =
              count > 0 ? '${segment.label} ($count)' : segment.label;
          return AsfarChip(
            label: label,
            active: segment == selected,
            onTap: () => onSelect(segment),
          );
        },
      ),
    );
  }
}
