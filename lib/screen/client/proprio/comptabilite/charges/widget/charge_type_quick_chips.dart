import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Rangée de chips d'accès rapide aux types de charge les plus fréquents,
/// pour accélérer la saisie du formulaire. Tap → sélectionne le type.
class ChargeTypeQuickChips extends StatelessWidget {
  final TypeCharge selected;
  final ValueChanged<TypeCharge> onSelect;

  const ChargeTypeQuickChips({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  /// Types courants proposés en accès rapide.
  static const _quickTypes = [
    TypeCharge.electricite,
    TypeCharge.eau,
    TypeCharge.menage,
    TypeCharge.maintenance,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final t in _quickTypes)
          AsfarChip(
            label: '${t.icon} ${t.label}',
            active: t == selected,
            onTap: () => onSelect(t),
          ),
      ],
    );
  }
}
