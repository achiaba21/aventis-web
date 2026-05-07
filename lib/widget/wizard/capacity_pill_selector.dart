import 'package:flutter/material.dart';

import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Sélecteur en pills pour un nombre entier petit (1, 2, 3, …, max+).
///
/// La dernière pill ("max+") laisse la valeur en l'état si déjà ≥ max,
/// sinon la passe à `max`. Utilisé pour les chambres dans le wizard.
class CapacityPillSelector extends StatelessWidget {
  const CapacityPillSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.options = const [1, 2, 3],
    this.maxLabel = "4+",
    this.maxValue = 4,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final List<int> options;
  final String maxLabel;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Espacement.gapSection,
      runSpacing: Espacement.gapItem,
      children: [
        ...options.map((option) {
          final selected = value == option;
          return _Pill(
            label: option.toString(),
            selected: selected,
            onTap: () => onChanged(option),
          );
        }),
        _Pill(
          label: maxLabel,
          selected: value >= maxValue,
          onTap: () => onChanged(value >= maxValue ? value : maxValue),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.accent : AppColors.surfaceVariant;
    final fg = selected ? AppColors.background : AppColors.textPrimary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Espacement.circle),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc,
          vertical: Espacement.paddingInput,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Espacement.circle),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.divider,
          ),
        ),
        child: TextSeed(
          label,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
