import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/display/amenities_display.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Widget affichant les équipements et commodités de l'appartement
/// dans une grille avec icônes et style amélioré
class AppartOffer extends StatelessWidget {
  const AppartOffer({super.key, required this.appartement});
  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    // Convertir les offres en liste de Commodite
    final List<Commodite> commodites = appartement.offres
            ?.where((offre) => offre.commodite != null)
            .map((offre) => offre.commodite!)
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          children: [
            Icon(
              Icons.home_work_outlined,
              color: AppColors.accent,
              size: 22,
            ),
            Gap(Espacement.gapItem),
            TextSeed(
              "Équipements et commodités",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ],
        ),

        Gap(Espacement.gapSection),

        // Affichage avec AmenitiesDisplay (style de l'écran d'édition)
        AmenitiesDisplay(commodites: commodites),
      ],
    );
  }
}
