import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/form/discount_manager.dart';
import 'package:asfar/widget/form/form_section.dart';

/// Section pour gérer les remises de longue durée
class DiscountsSection extends StatelessWidget {
  const DiscountsSection({
    super.key,
    required this.appartement,
    required this.onAppartementChanged,
  });

  final Appartement? appartement;
  final Function(Appartement) onAppartementChanged;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: "Remises pour longue durée (optionnel)",
      child: DiscountManager(
        remise: appartement?.remises,
        onRemiseChanged: (remise) {
          final updated = appartement?.copyWith(remises: remise);
          if (updated != null) {
            onAppartementChanged(updated);
          }
        },
      ),
    );
  }
}
