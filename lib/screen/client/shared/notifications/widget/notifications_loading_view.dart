import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `NotificationsScreen` — 3 cards 72px.
class NotificationsLoadingView extends StatelessWidget {
  const NotificationsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
      children: const [
        ShimmerCard(height: 72),
        SizedBox(height: 10),
        ShimmerCard(height: 72),
        SizedBox(height: 10),
        ShimmerCard(height: 72),
      ],
    );
  }
}
