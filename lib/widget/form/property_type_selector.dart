import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class PropertyTypeOption {
  final String label;
  final IconData icon;
  final String value;

  const PropertyTypeOption({
    required this.label,
    required this.icon,
    required this.value,
  });
}

class PropertyTypeSelector extends StatelessWidget {
  const PropertyTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final String? selectedType;
  final Function(String) onTypeSelected;

  static const List<PropertyTypeOption> propertyTypes = [
    PropertyTypeOption(label: "Home", icon: Icons.home, value: "home"),
    PropertyTypeOption(label: "Apartment/flat", icon: Icons.apartment, value: "apartment"),
    PropertyTypeOption(label: "Chamber and hall", icon: Icons.meeting_room, value: "chamber_hall"),
    PropertyTypeOption(label: "Single room", icon: Icons.single_bed, value: "single_room"),
    PropertyTypeOption(label: "Hostel", icon: Icons.school, value: "hostel"),
    PropertyTypeOption(label: "Hotel", icon: Icons.hotel, value: "hotel"),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: propertyTypes.map((type) {
        final isSelected = selectedType == type.value;
        return Container(
          margin: EdgeInsets.only(bottom: Espacement.gapSection),
          child: InkWell(
            onTap: () => onTypeSelected(type.value),
            borderRadius: BorderRadius.circular(Espacement.radius),
            child: Container(
              padding: EdgeInsets.all(Espacement.paddingBloc),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent.withOpacity(0.1) : AppColors.background,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(Espacement.radius),
              ),
              child: Row(
                children: [
                  Icon(
                    type.icon,
                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                    size: 24,
                  ),
                  SizedBox(width: Espacement.gapSection),
                  TextSeed(
                    type.label,
                    fontSize: 16,
                    color: isSelected ? AppColors.accent : AppColors.background,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}