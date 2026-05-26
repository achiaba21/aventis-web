import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Row scrollable horizontale des chips d'annonces — utilisée dans
/// `CalendarBookingsScreen` pour permettre au proprio de switcher d'annonce.
///
/// Sticky en haut de l'écran via `SliverPersistentHeader` (géré par le screen).
class AppartementChipsRow extends StatelessWidget {
  final List<Appartement> appartements;
  final int? selectedId;
  final void Function(Appartement appartement) onSelect;

  const AppartementChipsRow({
    super.key,
    required this.appartements,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          for (final a in appartements) ...[
            AsfarChip(
              label: a.titleSafe,
              active: a.id == selectedId,
              onTap: () => onSelect(a),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
