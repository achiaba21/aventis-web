import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Action bar sticky bottom du `ChargeDetailScreen`.
///
/// Sémantique post-2026-05-13 : chaque charge = un paiement déjà enregistré.
/// Les actions `markPaid` / `markUnpaid` ont été retirées. Subsistent
/// `edit` (modifier) et `delete` (supprimer).
class ChargeDetailActionsBar extends StatelessWidget {
  final ChargeDetailAction? actionInProgress;
  final void Function(ChargeDetailAction action) onAction;

  const ChargeDetailActionsBar({
    super.key,
    required this.onAction,
    this.actionInProgress,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final disabled = actionInProgress != null;

    return Container(
      padding: EdgeInsets.fromLTRB(18, 12, 18, 12 + mq.padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.bgElev1,
        border: Border(top: BorderSide(color: AppColors.line, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Modifier',
                size: ButtonSize.md,
                block: true,
                loading: actionInProgress == ChargeDetailAction.edit,
                onPressed: disabled
                    ? null
                    : () => onAction(ChargeDetailAction.edit),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedCustomButton(
                text: 'Supprimer',
                size: ButtonSize.md,
                block: true,
                loading: actionInProgress == ChargeDetailAction.delete,
                textColor: AppColors.danger,
                onPressed: disabled
                    ? null
                    : () => onAction(ChargeDetailAction.delete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
