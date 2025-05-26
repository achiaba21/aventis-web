import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class SuccessPayement extends StatelessWidget {
  static String routeName = "success-payement";

  const SuccessPayement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TextSeed("Paiement réussis")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: Espacement.gapSection,
        children: [
          TextSeed("Fantastique"),
          TextSeed(
            textAlign: TextAlign.center,
            "Votre chambre a été réservée, entrez vos réservations et vous pouvez commencer une conversation avec votre hôte.",
            maxLines: 2,
          ),
          CircleIcon(
            svgPath: "assets/icon/payment_success.svg",
            size: 64,
            neutral: true,
            color: Style.primaryColor,
          ),
        ],
      ),
    );
  }
}
