import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer 3 cards pour le `ProprioListingsScreen` pendant le
/// chargement initial.
class ProprioListingsLoadingView extends StatelessWidget {
  const ProprioListingsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 320),
    );
  }
}
