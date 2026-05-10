import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/period_switcher_segment.dart';
import 'package:asfar/theme/app_colors.dart';

/// Segmented control 4 options pour `ProprioFinancesScreen`.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireFinances`
/// (lignes 194-208) : fond `bgElev2` border `line` radius 12 padding 4.
/// Item actif : fond `bgElev3` + texte `text`. Inactif : transparent + `text3`.
class PeriodSwitcher extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;

  const PeriodSwitcher({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgElev2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: PeriodSwitcherSegment(
                option: option,
                active: option == selected,
                onTap: () => onSelect(option),
              ),
            ),
        ],
      ),
    );
  }
}
