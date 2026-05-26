import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/widget/badge/asfar_chip.dart';

/// Wrap 4 chips de moyen de paiement — wizard step 2.
///
/// Utilise la liste `MoyenPaiement.manualReservationOptions` (Espèces / Wave /
/// Orange Money / Virement) — alignée sur le proto.
class PaymentMethodChips extends StatelessWidget {
  final MoyenPaiement? value;
  final ValueChanged<MoyenPaiement> onSelect;

  const PaymentMethodChips({
    super.key,
    required this.value,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in MoyenPaiement.manualReservationOptions)
          AsfarChip(
            label: m.label,
            active: value == m,
            onTap: () => onSelect(m),
          ),
      ],
    );
  }
}
