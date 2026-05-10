import 'package:flutter/material.dart';
import 'package:asfar/screen/client/locataire/booking/widget/amenity_item.dart';
import 'package:asfar/theme/app_colors.dart';

/// Une ligne de la `AmenitiesGrid` : icône accent + label.
class AmenityRow extends StatelessWidget {
  final AmenityItem item;

  const AmenityRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(item.icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
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
