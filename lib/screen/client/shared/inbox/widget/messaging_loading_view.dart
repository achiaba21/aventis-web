import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `MessagingListScreen` — 4 cards 76px.
class MessagingLoadingView extends StatelessWidget {
  const MessagingLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: const [
        ShimmerCard(height: 76),
        SizedBox(height: 10),
        ShimmerCard(height: 76),
        SizedBox(height: 10),
        ShimmerCard(height: 76),
        SizedBox(height: 10),
        ShimmerCard(height: 76),
      ],
    );
  }
}
