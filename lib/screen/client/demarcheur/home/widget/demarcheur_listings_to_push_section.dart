import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/appart_display.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/listing_push_card.dart';
import 'package:asfar/util/calc/demarcheur_stats_calculator.dart';
import 'package:asfar/widget/feedback/empty_state.dart';
import 'package:asfar/widget/text/section_header.dart';

/// Section « Logements à pousser » du `DemarcheurDashboard` — carrousel
/// horizontal de `ListingPushCard` (ou EmptyState si aucun bien éligible).
class DemarcheurListingsToPushSection extends StatelessWidget {
  final List<Appartement> appartements;
  final VoidCallback? onSeeAll;
  final void Function(Appartement appart)? onListingTap;

  const DemarcheurListingsToPushSection({
    super.key,
    required this.appartements,
    this.onSeeAll,
    this.onListingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Logements à pousser',
          actionLabel: 'Voir tout',
          onActionTap: onSeeAll,
        ),
        if (appartements.isEmpty)
          EmptyState.inline(
            icon: Icons.home_work_outlined,
            title: 'Aucun logement disponible',
            body: 'Les logements éligibles apparaîtront ici.',
          )
        else
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: appartements.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final a = appartements[i];
                return ListingPushCard(
                  appartement: a,
                  estimatedCommission: ReferralCommissionHelper.estimate(
                      pricePerNight: a.priceAmount),
                  onTap: onListingTap == null
                      ? null
                      : () => onListingTap!(a),
                );
              },
            ),
          ),
      ],
    );
  }
}
