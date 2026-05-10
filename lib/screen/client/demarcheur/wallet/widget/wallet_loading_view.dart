import 'package:flutter/material.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Placeholder shimmer du `DemarcheurWalletScreen` pendant le chargement
/// initial : grosse card du solde + 3 lignes de transactions.
class WalletLoadingView extends StatelessWidget {
  const WalletLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      children: const [
        ShimmerCard(height: 180),
        SizedBox(height: 22),
        ShimmerCard(height: 64),
        SizedBox(height: 10),
        ShimmerCard(height: 64),
        SizedBox(height: 10),
        ShimmerCard(height: 64),
      ],
    );
  }
}
