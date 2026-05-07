import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/form/form_section.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/input/number_input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Section pour définir le prix et la description
class PricingSection extends StatelessWidget {
  const PricingSection({
    super.key,
    required this.appartement,
    required this.onAppartementChanged,
    required this.currency,
  });

  final Appartement? appartement;
  final Function(Appartement) onAppartementChanged;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: "Prix et description",
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: NumberInputField(
                  libelle: "Prix (par nuit)",
                  placeHolder: "850",
                  initialValue: appartement?.prix,
                  allowDecimals: false,
                  minValue: 0,
                  onValueChanged: (prix) {
                    final updated = appartement?.copyWith(prix: prix ?? 0);
                    if (updated != null) {
                      onAppartementChanged(updated);
                    }
                  },
                ),
              ),
              SizedBox(width: Espacement.gapSection),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeed(
                      "Devise",
                      fontSize: 14,
                      color: AppColors.background,
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Espacement.paddingInput,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(Espacement.radius),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextSeed(
                              currency,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent,
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Espacement.gapSection),
          InputField(
            libelle: "Ajouter un titre à votre espace",
            placeHolder: "chambre simple de luxe pour deux",
            maxLength: 100,
            initialValue: appartement?.titre,
            onChange: (value) {
              final titre = value ?? "";
              final updated = appartement?.copyWith(titre: titre);
              if (updated != null) {
                onAppartementChanged(updated);
              }
              return null;
            },
          ),
          SizedBox(height: Espacement.gapSection),
          InputField(
            libelle: "Ajouter une description",
            placeHolder: "ajouter une description ici",
            maxLines: 5,
            maxLength: 500,
            initialValue: appartement?.description,
            onChange: (value) {
              final description = value ?? "";
              final updated = appartement?.copyWith(description: description);
              if (updated != null) {
                onAppartementChanged(updated);
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
