import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/card/appartement_preview_card.dart';

/// Liste verticale "Recommandés pour vous" du `LocataireHomeScreen`.
///
/// Le statut favori est géré PAR CARTE via `FavoriteToggleButton`
/// (BlocSelector) : un like ne reconstruit plus la liste entière (PERF-03).
class RecommendedListingsList extends StatelessWidget {
  final List<Appartement> appartements;
  final void Function(Appartement appartement)? onTap;

  const RecommendedListingsList({
    super.key,
    required this.appartements,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < appartements.length; i++) ...[
          AppartementPreviewCard(
            appartement: appartements[i],
            onTap: onTap == null ? null : () => onTap!(appartements[i]),
          ),
          if (i != appartements.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }
}
