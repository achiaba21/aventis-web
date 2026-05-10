import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer 4 cards pour le ProprioReservationsScreen pendant
/// le chargement initial.
class ReservationsLoadingView extends StatelessWidget {
  const ReservationsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 60, 18, 100),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const ShimmerCard(height: 70),
    );
  }
}
