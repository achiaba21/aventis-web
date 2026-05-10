import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenity_item.dart';
import 'package:asfar/theme/app_colors.dart';

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
              Expanded(child: _row(items[i])),
              const SizedBox(width: 10),
              Expanded(
                child: i + 1 < items.length
                    ? _row(items[i + 1])
                    : const SizedBox.shrink(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _row(AmenityItem a) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(a.icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              a.label,
              style: const TextStyle(fontSize: 14, color: AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
