import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/amenity_chip_grid.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Étape 4 du wizard — équipements.
///
/// Reproduit `proprietaire-extras.jsx::step 4` (lignes 198-216) :
/// 2 sections (Essentiels + Confort) avec chips multi-sélection.
class StepAmenities extends StatelessWidget {
  final Set<String> active;
  final ValueChanged<String> onToggle;

  const StepAmenities({
    super.key,
    required this.active,
    required this.onToggle,
  });

  static const essentials = [
    'WiFi',
    'WiFi fibre',
    'Clim',
    'Eau chaude',
    'Cuisine équipée',
    'Lave-linge',
    'Frigo',
    'TV',
  ];

  static const comfort = [
    'Parking',
    'Sécurité 24/7',
    'Piscine',
    'Salle de sport',
    'Ascenseur',
    'Vue mer',
    'Vue lagune',
    'Balcon',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Équipements', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Sélectionnez tout ce que votre logement propose.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        AmenityChipGrid(
          eyebrow: 'Essentiels',
          amenities: essentials,
          active: active,
          onToggle: onToggle,
        ),
        const SizedBox(height: 18),
        AmenityChipGrid(
          eyebrow: 'Confort',
          amenities: comfort,
          active: active,
          onToggle: onToggle,
        ),
      ],
    );
  }
}
