import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/container/block2.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartBottom extends StatelessWidget {
  const AppartBottom({
    super.key,
    this.appartement,
    this.reservation,
    this.validationText,
    this.onPress,
  });
  final Appartement? appartement;
  final void Function()? onPress;
  final Reservation? reservation;
  final String? validationText;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppData>(
      builder: (context, appData, child) {
        final req = appData.req;
        final plage = reservation?.plage ?? req?.plage;

    // Calculer le prix avec réduction si applicable
    double prixCalcule = (reservation?.prix ?? appartement?.prix ?? req?.appartement?.prix ?? 0).toDouble();

    // Appliquer les réductions si un séjour est sélectionné et qu'il y a des remises
    if (plage != null && appartement?.remises != null) {
      final nombreJours = plage.duration.inDays;
      final conditionApplicable = appartement!.remises!.matchCondition(nombreJours);

      if (conditionApplicable?.montant != null) {
        // Le montant est déjà le nouveau prix réduit
        prixCalcule = conditionApplicable!.montant!;
      }
    }

    final prix = prixCalcule.toInt();
    final color = Style.containerColor3;

    // Formater les prix avec la fonction de formatage
    final prixFormate = helpAmountFormate(prix, decim: false);

    // Calculer les textes d'affichage
    String prixParNuitTexte = "$prixFormate FCFA / nuit";
    String? prixTotalTexte;

    if (plage != null) {
      final nombreJours = plage.duration.inDays;
      if (nombreJours > 0) {
        final prixTotal = prix * nombreJours;
        final prixTotalFormate = helpAmountFormate(prixTotal, decim: false);
        prixTotalTexte = "Total : $prixTotalFormate FCFA";
      }
    }

        deboger(plage);
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 60,
            maxHeight: 100,
          ),
          child: Block2(
            padding: EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 8),
            child: Row(
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prix par nuit (toujours affiché)
                    TextSeed(prixParNuitTexte, color: color, fontSize: 12),

                    // Prix total (affiché seulement si plage sélectionnée)
                    if (prixTotalTexte != null)
                      TextSeed(
                        prixTotalTexte,
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),

                    // Plage de dates
                    if (plage != null)
                      TextSeed(formateRangeTimeShort(plage), color: color, fontSize: 12),
                  ],
                ),
              ),
              Spacer(),
              PlainButton(value: validationText ?? "Réserver", onPress: onPress),
            ],
            ),
          ),
        );
      },
    );
  }
}
