import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class TotaleInfo extends StatelessWidget {
  const TotaleInfo(this.request, {super.key});
  final ReservationReq request;

  @override
  Widget build(BuildContext context) {
    final appart = request.appartement!;
    final plage = request.plage!;

    final days = plage.duration.inDays;
    final pris = appart.prix ?? 0;
    final cur = request.cur;
    final total = days * pris;
    return Column(
      spacing: Espacement.gapItem,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed("Pris de la reservation"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSeed("$pris $cur x $days nuits"),
            TextSeed("${helpAmountFormate(total)} $cur"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSeed("Total ($cur)"),
            TextSeed("${helpAmountFormate(total)} $cur"),
          ],
        ),
      ],
    );
  }
}
