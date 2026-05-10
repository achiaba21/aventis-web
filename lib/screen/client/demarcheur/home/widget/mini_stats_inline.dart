import 'package:flutter/material.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bloc de 3 stats en ligne avec séparateurs verticaux 1 px.
///
/// Reproduit le sous-bloc du `WalletHeroCard` (proto `demarcheur.jsx:51-71`) :
/// fond `rgba(255,255,255,0.05)`, bordure `rgba(255,255,255,0.08)`,
/// radius 12 px, padding 12. Eyebrow 9 px + valeur mono 15 px bold.
///
/// Chaque [MiniStatItem] peut overrider la couleur de la valeur (utilisé
/// pour le warn « En attente »).
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
            Expanded(child: _stat(items[i])),
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

  Widget _stat(MiniStatItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label.toUpperCase(),
          style: AppTextStyles.eyebrow.copyWith(
            fontSize: 9,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.value,
          style: AppTextStyles.mono(TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: item.valueColor ?? Colors.white,
          )),
        ),
      ],
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
