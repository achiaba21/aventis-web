import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/form/form_section.dart';
import 'package:asfar/widget/form/property_type_selector.dart';

/// Section pour sélectionner le type de propriété
class PropertyTypeSection extends StatelessWidget {
  const PropertyTypeSection({
    super.key,
    required this.appartement,
    required this.onAppartementChanged,
  });

  final Appartement? appartement;
  final Function(Appartement) onAppartementChanged;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: "Qu'est-ce qui décrit le mieux votre espace",
      child: PropertyTypeSelector(
        selectedType: appartement?.typeLocation,
        onTypeSelected: (type) {
          final updated = appartement?.copyWith(typeLocation: type);
          if (updated != null) {
            onAppartementChanged(updated);
          }
        },
      ),
    );
  }
}
