import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `MessagingThreadScreen` pendant le chargement
/// initial — 3 bubbles 48px.
class ThreadLoadingView extends StatelessWidget {
  const ThreadLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      children: const [
        ShimmerCard(height: 48),
        SizedBox(height: 8),
        ShimmerCard(height: 48),
        SizedBox(height: 8),
        ShimmerCard(height: 48),
      ],
    );
  }
}
