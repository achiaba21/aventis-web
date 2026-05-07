import 'package:flutter/material.dart';
import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/widget/text/icon_text.dart';

/// Widget d'affichage d'une commodité/équipement
///
/// PRINCIPE SOLID - Single Responsibility (S) :
/// Responsabilité unique : afficher une commodité avec son icône et son label
class OfferItem extends StatelessWidget {
  const OfferItem({super.key, required this.commodite});
  final Commodite commodite;

  @override
  Widget build(BuildContext context) {
    return IconText(
      svgPath: null, // Les SVG ne sont plus utilisés
      image: commodite.getIcon(), // Utilise la méthode getIcon() de Commodite
      text: commodite.getLabel(), // Utilise la méthode getLabel() de Commodite
    );
  }
}
