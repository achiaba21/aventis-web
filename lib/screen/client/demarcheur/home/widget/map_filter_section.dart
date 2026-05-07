import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class MapFilterSection extends StatelessWidget {
  final LatLng? mapCenter;
  final VoidCallback onPickLocation;
  final VoidCallback onClearLocation;

  const MapFilterSection({
    super.key,
    required this.mapCenter,
    required this.onPickLocation,
    required this.onClearLocation,
  });

  @override
  Widget build(BuildContext context) {
    final center = mapCenter;
    if (center == null) {
      return GestureDetector(
        onTap: onPickLocation,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, color: AppColors.accent, size: 14),
            const SizedBox(width: 4),
            TextSeed('Position carte', fontSize: 12, color: AppColors.accent),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onPickLocation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: AppColors.accent, size: 14),
          const SizedBox(width: 4),
          TextSeed(
            '${center.latitude.toStringAsFixed(3)}, ${center.longitude.toStringAsFixed(3)}',
            fontSize: 12,
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onClearLocation,
            child: Icon(Icons.close, color: AppColors.textMuted, size: 14),
          ),
        ],
      ),
    );
  }
}
