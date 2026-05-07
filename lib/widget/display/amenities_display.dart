import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget d'affichage en lecture seule des commodités
///
/// PRINCIPE SOLID - Single Responsibility (S) :
/// Responsabilité unique : afficher les commodités sans possibilité de sélection
/// Différent de AmenitiesGrid qui permet la sélection
class AmenitiesDisplay extends StatelessWidget {
  final List<Commodite> commodites;

  const AmenitiesDisplay({
    super.key,
    required this.commodites,
  });

  @override
  Widget build(BuildContext context) {
    if (commodites.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: TextSeed(
            'Aucune commodité disponible',
            fontSize: 14,
            color: AppColors.inactive,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: commodites.length,
      itemBuilder: (context, index) {
        final commodite = commodites[index];
        return _buildAmenityItem(commodite);
      },
    );
  }

  Widget _buildAmenityItem(Commodite commodite) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            commodite.getIcon(),
            size: 20,
            color: AppColors.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextSeed(
              commodite.getLabel(),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
