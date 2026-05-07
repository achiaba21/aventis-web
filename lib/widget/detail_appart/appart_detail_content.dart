import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/request/reservation_req.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_offer.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_review.dart';
import 'package:asfar/screen/client/locataire/home/widget/house_rule.dart';
import 'package:asfar/screen/client/locataire/home/widget/sejour_selector.dart';
import 'package:asfar/widget/detail_appart/detail_section_card.dart';
import 'package:asfar/widget/item/appart/appart_titre_info.dart';
import 'package:asfar/widget/item/appart/remise_info.dart';
import 'package:asfar/widget/map/appart_map_section.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Contenu réutilisable des détails d'un appartement
/// Ordre des sections (pour locataire) :
/// 1. Titre + Prix
/// 2. Réductions (juste après le prix)
/// 3. Description
/// 4. Localisation (carte approximative)
/// 5. Commodités
/// 6. Avis
/// 7. Sélection de dates
/// 8. Règles de la maison
class AppartDetailContent extends StatelessWidget {
  const AppartDetailContent({
    super.key,
    required this.appartement,
    this.showSejourSelector = true,
    this.showHouseRules = true,
    this.showMap = true,
    this.isOwner = false,
  });

  final Appartement appartement;
  final bool showSejourSelector;
  final bool showHouseRules;
  final bool showMap;
  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    final reservationBloc = context.read<ReservationBloc>();

    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, state) {
        final req = state.currentReq;
        final nombreJours = req?.plage?.duration.inDays ?? 0;

        return Padding(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Titre et informations principales (avec prix)
              AppartTitreInfo(appartement),

              Gap(Espacement.gapSection),

              // 2. Informations de remise (juste après le prix)
              if (appartement.remises?.conditions?.isNotEmpty == true) ...[
                RemiseInfo(
                  remises: appartement.remises,
                  prixBase: appartement.prix?.toDouble() ?? 0.0,
                  selectedDays: nombreJours > 0 ? nombreJours : null,
                ),
                Gap(Espacement.gapSection),
              ],

              // 3. Description
              DetailSectionCard(
                title: "Description",
                icon: Icons.description_outlined,
                child: TextSeed(
                  appartement.description?.isNotEmpty == true
                      ? appartement.description!
                      : "Aucune description disponible pour cet appartement.",
                  textAlign: TextAlign.justify,
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              Gap(Espacement.gapSection),

              // 4. Localisation (carte approximative)
              if (showMap) ...[
                DetailSectionCard(
                  title: "Localisation",
                  icon: Icons.location_on_outlined,
                  child: AppartMapSection(
                    appartement: appartement,
                    isOwner: isOwner,
                    showExactLocation: false,
                    onMaskedTap: () {
                      // Action quand on tape sur la carte masquée
                    },
                  ),
                ),
                Gap(Espacement.gapSection),
              ],

              // 5. Équipements et commodités
              AppartOffer(appartement: appartement),

              Gap(Espacement.gapSection),

              // 6. Avis
              AppartReview(appartement),

              Gap(Espacement.gapSection),

              // 7. Sélecteur de séjour (optionnel - seulement pour locataire)
              if (showSejourSelector) ...[
                SejourSelector(
                  selectedRange: req?.plage,
                  onSelectRange: (plage) {
                    if (req == null) {
                      final newReq = ReservationReq();
                      newReq.appartement = appartement;
                      newReq.plage = plage;
                      newReq.cur = 'F CFA';
                      reservationBloc.add(SetReservationReq(newReq));
                    } else {
                      req.plage = plage;
                      reservationBloc.add(SetReservationReq(req));
                    }
                  },
                ),
                Gap(Espacement.gapSection),
              ],

              // 8. Règles de la maison (optionnelles)
              if (showHouseRules) ...[
                HouseRule(rules: appartement.rules),
                Gap(Espacement.gapSection),
              ],

              // Espace en bas pour le bottom bar
              Gap(Espacement.gapSection * 4),
            ],
          ),
        );
      },
    );
  }
}
