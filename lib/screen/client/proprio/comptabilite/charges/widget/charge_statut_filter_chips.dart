import 'package:flutter/material.dart';
import 'package:asfar/bloc/charge_filter_cubit/charge_filter_cubit.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Chips horizontaux pour le filtre statut de la liste des charges.
///
/// 4 valeurs : Toutes / Payées / Impayées / En retard. Le state actif vient
/// du `ChargeFilterCubit` parent.
class ChargeStatutFilterChips extends StatelessWidget {
  final ChargeStatutFilter selected;
  final ValueChanged<ChargeStatutFilter> onSelect;

  const ChargeStatutFilterChips({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const _options = [
    (ChargeStatutFilter.tous, 'Toutes'),
    (ChargeStatutFilter.payee, 'Payées'),
    (ChargeStatutFilter.impayee, 'Impayées'),
    (ChargeStatutFilter.enRetard, 'En retard'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          for (final opt in _options) ...[
            AsfarChip(
              label: opt.$2,
              active: selected == opt.$1,
              onTap: () => onSelect(opt.$1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
