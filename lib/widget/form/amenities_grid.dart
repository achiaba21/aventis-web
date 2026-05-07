import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class AmenityOption {
  final String label;
  final IconData icon;
  final String value;

  const AmenityOption({
    required this.label,
    required this.icon,
    required this.value,
  });
}

class AmenitiesGrid extends StatelessWidget {
  const AmenitiesGrid({
    super.key,
    required this.selectedAmenities,
    required this.onAmenityToggle,
  });

  final List<String> selectedAmenities;
  final Function(String) onAmenityToggle;

  static const List<AmenityOption> amenities = [
    AmenityOption(label: "Piscine", icon: Icons.pool, value: "pool"),
    AmenityOption(label: "Parking", icon: Icons.local_parking, value: "carpark"),
    AmenityOption(label: "Salle de sport", icon: Icons.fitness_center, value: "gym"),
    AmenityOption(label: "Cuisine", icon: Icons.kitchen, value: "kitchen"),
    AmenityOption(label: "Eau courante", icon: Icons.water_drop, value: "water_flow"),
    AmenityOption(label: "WiFi", icon: Icons.wifi, value: "wifi"),
    AmenityOption(label: "Climatisation", icon: Icons.ac_unit, value: "ac"),
    AmenityOption(label: "Balcon", icon: Icons.balcony, value: "balcony"),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3,
      ),
      itemCount: amenities.length,
      itemBuilder: (context, index) {
        final amenity = amenities[index];
        final isSelected = selectedAmenities.contains(amenity.value);

        return InkWell(
          onTap: () => onAmenityToggle(amenity.value),
          borderRadius: BorderRadius.circular(Espacement.radius),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Espacement.paddingBloc / 2,
              vertical: Espacement.paddingBloc / 3,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accent.withValues(alpha: 0.1) : AppColors.background,
              border: Border.all(
                color: isSelected ? AppColors.accent : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(Espacement.radius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  amenity.icon,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextSeed(
                    amenity.label,
                    fontSize: 14,
                    color: isSelected ? AppColors.accent : AppColors.background,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}