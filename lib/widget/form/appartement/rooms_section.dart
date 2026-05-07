import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/form/counter_field.dart';
import 'package:asfar/widget/form/form_section.dart';

/// Section pour définir le nombre de lits et salles de bain
class RoomsSection extends StatelessWidget {
  const RoomsSection({
    super.key,
    required this.appartement,
    required this.onAppartementChanged,
    required this.guests,
    required this.onGuestsChanged,
  });

  final Appartement? appartement;
  final Function(Appartement) onAppartementChanged;
  final int guests;
  final Function(int) onGuestsChanged;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: "Nombre de lits et de salles de bain",
      child: Column(
        children: [
          CounterField(
            label: "Chambre(s)",
            icon: Icons.bed,
            value: appartement?.nbChambres ?? 0,
            onChanged: (value) {
              final updated = appartement?.copyWith(nbChambres: value);
              if (updated != null) {
                onAppartementChanged(updated);
              }
            },
          ),
          CounterField(
            label: "Lit(s)",
            icon: Icons.single_bed,
            value: appartement?.nbLits ?? 0,
            onChanged: (value) {
              final updated = appartement?.copyWith(nbLits: value);
              if (updated != null) {
                onAppartementChanged(updated);
              }
            },
          ),
          CounterField(
            label: "Salle(s) de bain",
            icon: Icons.bathroom,
            value: appartement?.nbDouches ?? 0,
            onChanged: (value) {
              final updated = appartement?.copyWith(nbDouches: value);
              if (updated != null) {
                onAppartementChanged(updated);
              }
            },
          ),
          CounterField(
            label: "Invité(s)",
            icon: Icons.people,
            value: guests,
            onChanged: onGuestsChanged,
          ),
        ],
      ),
    );
  }
}
