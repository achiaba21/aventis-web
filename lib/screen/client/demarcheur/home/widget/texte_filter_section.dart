import 'package:flutter/material.dart';
import 'package:asfar/model/locolite/lieux/commune.dart';
import 'package:asfar/model/locolite/lieux/ville.dart';
import 'package:asfar/widget/input/custom_selector.dart';

class TexteFilterSection extends StatelessWidget {
  final List<Ville> villes;
  final List<Commune> communes;
  final Ville? selectedVille;
  final Commune? selectedCommune;
  final ValueChanged<Ville?> onVilleChanged;
  final ValueChanged<Commune?> onCommuneChanged;

  const TexteFilterSection({
    super.key,
    required this.villes,
    required this.communes,
    required this.selectedVille,
    required this.selectedCommune,
    required this.onVilleChanged,
    required this.onCommuneChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomSelector<Ville>(
            items: villes,
            label: (v) => v.nom ?? '',
            selected: selectedVille,
            onChanged: onVilleChanged,
            hint: 'Ville',
            title: 'Sélectionner une ville',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: CustomSelector<Commune>(
            items: communes,
            label: (c) => c.nom ?? '',
            selected: selectedCommune,
            onChanged: onCommuneChanged,
            hint: 'Commune',
            title: 'Sélectionner une commune',
          ),
        ),
      ],
    );
  }
}
