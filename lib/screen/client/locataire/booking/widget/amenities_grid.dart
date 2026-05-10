import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenity_item.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenity_row.dart';

/// Grille d'équipements 2 colonnes du Detail logement.
///
/// Chaque ligne : icon accent or + label (text 14). Pas de fond, juste
/// padding vertical.
class AmenitiesGrid extends StatelessWidget {
  final List<AmenityItem> items;

  const AmenitiesGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i += 2)
          Row(
            children: [
              Expanded(child: AmenityRow(item: items[i])),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < items.length
                    ? AmenityRow(item: items[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
      ],
    );
  }
}
