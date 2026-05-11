import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/rooms_type_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Étape 1 du wizard d'ajout d'appartement — choix du nombre de pièces.
///
/// Reproduit `proprietaire-extras.jsx::step 1` (lignes 46-90).
/// 5 cards en grille 2 colonnes (Studio, 2/3/4/5+ pièces).
class StepRoomsType extends StatelessWidget {
  final String? selectedRooms;
  final ValueChanged<String> onSelect;

  const StepRoomsType({
    super.key,
    required this.selectedRooms,
    required this.onSelect,
  });

  static const _options = [
    _RoomOption(id: 'Studio', label: 'Studio', subtitle: 'Pièce unique séjour + coin nuit'),
    _RoomOption(id: '2 pièces', label: '2 pièces', subtitle: 'Séjour + 1 chambre'),
    _RoomOption(id: '3 pièces', label: '3 pièces', subtitle: 'Séjour + 2 chambres'),
    _RoomOption(id: '4 pièces', label: '4 pièces', subtitle: 'Séjour + 3 chambres'),
    _RoomOption(id: '5+ pièces', label: '5+ pièces', subtitle: 'Grande résidence'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Combien de pièces ?', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Toutes les annonces Asfar sont des résidences meublées. '
          'Le nombre de pièces détermine la catégorie de votre bien.',
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
          itemCount: _options.length,
          itemBuilder: (_, i) {
            final option = _options[i];
            return RoomsTypeCard(
              label: option.label,
              subtitle: option.subtitle,
              active: selectedRooms == option.id,
              onTap: () => onSelect(option.id),
            );
          },
        ),
      ],
    );
  }
}

class _RoomOption {
  final String id;
  final String label;
  final String subtitle;
  const _RoomOption({
    required this.id,
    required this.label,
    required this.subtitle,
  });
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
              'On compte le séjour + chambres. Salle de bain et cuisine ne comptent pas.',
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
