import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/status_pill.dart';

/// Row de 3 status pills statistiques — Dashboard démarcheur.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurDashboard` (lignes 93-107).
class StatusPillsRow extends StatelessWidget {
  final List<StatusPillItem> items;

  const StatusPillsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: StatusPill(item: items[i])),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class StatusPillItem {
  final String value;
  final String label;
  final Color? valueColor;

  const StatusPillItem({
    required this.value,
    required this.label,
    this.valueColor,
  });
}
