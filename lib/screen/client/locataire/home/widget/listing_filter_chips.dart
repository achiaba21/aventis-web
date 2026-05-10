import 'package:flutter/material.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Chips de filtre horizontales scrollables du Home Locataire.
///
/// Reproduit la barre de filtres du proto : `Tout`, `Studio`, `1 chambre`,
/// `2+ chambres`, `Avec piscine`, `Court séjour`. Chip actif = accent-soft.
class ListingFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelect;

  const ListingFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          for (var i = 0; i < filters.length; i++) ...[
            AsfarChip(
              label: filters[i],
              active: filters[i] == selected,
              onTap: () => onSelect(filters[i]),
            ),
            if (i < filters.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
