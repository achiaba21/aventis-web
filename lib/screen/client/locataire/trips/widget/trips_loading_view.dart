import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `LocataireTripsScreen` pendant le chargement
/// initial — 3 cards 130px.
class TripsLoadingView extends StatelessWidget {
  const TripsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 60, 18, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 130),
    );
  }
}
