import 'package:flutter/material.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Row de chips de filtre du DemarcheurReferralsScreen.
///
/// 5 chips alignés sur le proto (`app.jsx::ReferralsScreen`) :
/// Toutes / En attente / Acceptées / Terminées / Refusées.
/// Layout horizontal scrollable.
class ReferralFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const ReferralFilterChips({
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
