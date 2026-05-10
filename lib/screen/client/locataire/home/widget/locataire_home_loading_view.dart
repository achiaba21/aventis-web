import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `LocataireHomeScreen` pendant le chargement
/// initial (4 cards 220px).
class LocataireHomeLoadingView extends StatelessWidget {
  const LocataireHomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 100, 18, 100),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 220),
    );
  }
}
