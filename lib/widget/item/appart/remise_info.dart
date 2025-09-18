import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/remise/remise.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class RemiseInfo extends StatelessWidget {
  const RemiseInfo({
    super.key,
    required this.remises,
    required this.prixBase,
  });

  final Remise? remises;
  final double prixBase;

  @override
  Widget build(BuildContext context) {
    // Vérifier si des remises existent
    if (remises?.conditions == null || remises!.conditions!.isEmpty) {
      return SizedBox.shrink();
    }

    // Trier les conditions par nombre de jours croissant
    final conditions = List.from(remises!.conditions!)
      ..sort((a, b) => (a.days ?? 0).compareTo(b.days ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.local_offer,
              color: Style.primaryColor,
              size: 20,
            ),
            Gap(Espacement.gapItem),
            TextSeed(
              "Réductions pour séjours longs",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        Gap(Espacement.gapItem),
        Container(
          padding: EdgeInsets.all(Espacement.paddingInput),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(Espacement.radius),
            border: Border.all(
              color: Colors.green.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: conditions.map((condition) {
              if (condition.days == null || condition.montant == null) {
                return SizedBox.shrink();
              }

              // Le montant est déjà le nouveau prix
              final prixReduit = condition.montant!;
              final prixReduitFormate = prixReduit.toStringAsFixed(0);
              final prixBaseFormate = prixBase.toStringAsFixed(0);

              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextSeed(
                        "À partir de ${condition.days} jour${condition.days! > 1 ? 's' : ''}",
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextSeed(
                          "$prixReduitFormate FCFA/nuit",
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                        Text(
                          "au lieu de $prixBaseFormate",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}