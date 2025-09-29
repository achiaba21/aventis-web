import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/util/price_calculator.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class TotaleInfo extends StatelessWidget {
  const TotaleInfo(this.request, {super.key});
  final ReservationReq request;

  @override
  Widget build(BuildContext context) {
    final appart = request.appartement!;
    final plage = request.plage!;

    final days = plage.duration.inDays;
    final prixBase = (appart.prix ?? 0).toDouble();
    final cur = request.cur;

    // Calculer le prix avec remises
    final prixParNuit = PriceCalculator.getDiscountedNightPrice(
      prixBase,
      appart.remises,
      days
    );
    final total = PriceCalculator.calculateTotalPrice(
      prixBase,
      appart.remises,
      days
    );
    return Column(
      spacing: Espacement.gapItem,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed("Pris de la reservation"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSeed("${prixParNuit.toInt()} $cur x $days nuits"),
            TextSeed("${helpAmountFormate(total.toInt())} $cur"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSeed("Total ($cur)"),
            TextSeed("${helpAmountFormate(total.toInt())} $cur"),
          ],
        ),
      ],
    );
  }
}
