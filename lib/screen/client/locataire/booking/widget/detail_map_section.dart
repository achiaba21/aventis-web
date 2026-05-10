import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/widget/map/map_pin_marker.dart';
import 'package:asfar/widget/map/map_placeholder.dart';

/// Section "Emplacement" du Detail logement.
///
/// `MapPlaceholder` 180px avec [MapPinMarker] centré + card adresse en
/// bas-gauche (titre quartier, ville + sub "L'adresse exacte sera
/// communiquée après réservation").
class DetailMapSection extends StatelessWidget {
  final String area;
  final String city;
  final double height;

  const DetailMapSection({
    super.key,
    required this.area,
    required this.city,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: MapPlaceholder(
        radius: 16,
        child: Stack(
          children: [
            const Center(child: MapPinMarker()),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: const Color(0xD90A0A0B),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(color: AppColors.line, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$area, $city',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      "L'adresse exacte sera communiquée après réservation",
                      style: TextStyle(
                        color: AppColors.text3,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
