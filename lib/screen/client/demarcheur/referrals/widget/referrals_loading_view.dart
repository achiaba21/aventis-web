import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `DemarcheurReferralsScreen` pendant le
/// chargement initial — 3 cards 80px.
class ReferralsLoadingView extends StatelessWidget {
  const ReferralsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: const [
        ShimmerCard(height: 80),
        SizedBox(height: 10),
        ShimmerCard(height: 80),
        SizedBox(height: 10),
        ShimmerCard(height: 80),
      ],
    );
  }
}
