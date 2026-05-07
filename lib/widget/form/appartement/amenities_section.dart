import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/appartement_mapper_util.dart';
import 'package:asfar/widget/form/amenities_grid.dart';
import 'package:asfar/widget/form/form_section.dart';

/// Section pour sélectionner les commodités de l'espace
class AmenitiesSection extends StatelessWidget {
  const AmenitiesSection({
    super.key,
    required this.appartement,
    required this.onAppartementChanged,
    required this.selectedAmenities,
    required this.onSelectedAmenitiesChanged,
  });

  final Appartement? appartement;
  final Function(Appartement) onAppartementChanged;
  final List<String> selectedAmenities;
  final Function(List<String>) onSelectedAmenitiesChanged;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: "Quelles commodités y a-t-il dans cet espace",
      child: AmenitiesGrid(
        selectedAmenities: selectedAmenities,
        onAmenityToggle: (amenity) {
          final updatedAmenities = List<String>.from(selectedAmenities);
          if (updatedAmenities.contains(amenity)) {
            updatedAmenities.remove(amenity);
          } else {
            updatedAmenities.add(amenity);
          }

          // Mettre à jour la liste locale
          onSelectedAmenitiesChanged(updatedAmenities);

          // Convertir la liste d'amenities en liste d'Offre et mettre à jour l'appartement
          final offres = AppartementMapperUtil.amenitiesToOffres(updatedAmenities);
          final updated = appartement?.copyWith(offres: offres);
          if (updated != null) {
            onAppartementChanged(updated);
          }
        },
      ),
    );
  }
}
