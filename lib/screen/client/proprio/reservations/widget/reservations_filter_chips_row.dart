import 'package:flutter/material.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Row horizontale de chips filtres pour le `ProprioReservationsScreen`.
class ReservationsFilterChipsRow extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const ReservationsFilterChipsRow({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          return AsfarChip(
            label: f,
            active: f == selected,
            onTap: () => onSelect(f),
          );
        },
      ),
    );
  }
}
