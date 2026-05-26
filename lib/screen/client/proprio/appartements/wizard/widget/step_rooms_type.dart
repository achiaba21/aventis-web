import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/rooms_type_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Étape 1 du wizard d'ajout d'appartement — choix du type de logement.
///
/// Grille 2 colonnes alignée sur les 5 valeurs de `AppartementTypeLocation` :
/// Studio · 2 pièces · 3 pièces · 4 pièces · 5+ pièces. Le type détermine
/// le nombre de chambres au step 2 (cf. business-spec §4.1-4.2).
class StepRoomsType extends StatelessWidget {
  final AppartementTypeLocation? selectedType;
  final ValueChanged<AppartementTypeLocation> onSelect;

  const StepRoomsType({
    super.key,
    required this.selectedType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final types = AppartementTypeLocation.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quel type de logement ?', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Choisissez la typologie qui correspond le mieux à votre bien. '
          'Le nombre de chambres en découle automatiquement.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        const _RoomsHint(),
        const SizedBox(height: 18),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5,
          ),
          itemCount: types.length,
          itemBuilder: (_, i) {
            final type = types[i];
            return RoomsTypeCard(
              type: type,
              active: selectedType == type,
              onTap: () => onSelect(type),
            );
          },
        ),
      ],
    );
  }
}

class _RoomsHint extends StatelessWidget {
  const _RoomsHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_outlined, size: 16, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Studio = pièce unique sans salon. À partir de 2 pièces : 1 salon + chambres.',
              style: AppTextStyles.small.copyWith(
                fontSize: 12,
                height: 1.5,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
