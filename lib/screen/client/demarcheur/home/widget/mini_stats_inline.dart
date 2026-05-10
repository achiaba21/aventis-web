import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/mini_stat.dart';

/// Bloc de 3 stats en ligne avec séparateurs verticaux 1 px.
///
/// Reproduit le sous-bloc du `WalletHeroCard` (proto `demarcheur.jsx:51-71`).
class MiniStatsInline extends StatelessWidget {
  final List<MiniStatItem> items;

  const MiniStatsInline({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Expanded(child: MiniStat(item: items[i])),
            if (i != items.length - 1)
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.10),
              ),
          ],
        ],
      ),
    );
  }
}

/// Une stat affichée par le [MiniStatsInline].
class MiniStatItem {
  final String label;
  final String value;
  final Color? valueColor;

  const MiniStatItem({
    required this.label,
    required this.value,
    this.valueColor,
  });
}
