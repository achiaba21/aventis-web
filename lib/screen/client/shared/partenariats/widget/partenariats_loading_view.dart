import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `PartenariatsScreen` — 3 cards 92px.
class PartenariatsLoadingView extends StatelessWidget {
  const PartenariatsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: const [
        ShimmerCard(height: 92),
        SizedBox(height: 10),
        ShimmerCard(height: 92),
        SizedBox(height: 10),
        ShimmerCard(height: 92),
      ],
    );
  }
}
