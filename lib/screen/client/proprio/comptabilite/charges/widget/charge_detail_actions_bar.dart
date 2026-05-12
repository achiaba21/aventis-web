import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/charge_detail_action.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Action bar sticky bottom du `ChargeDetailScreen`.
///
/// Bouton principal : Marquer payée (si non payée) OU Marquer impayée
/// (si payée). Boutons secondaires : Éditer (or) et Supprimer (danger).
class ChargeDetailActionsBar extends StatelessWidget {
  final Charge charge;
  final ChargeDetailAction? actionInProgress;
  final void Function(ChargeDetailAction action) onAction;

  const ChargeDetailActionsBar({
    super.key,
    required this.charge,
    required this.onAction,
    this.actionInProgress,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isPaid = charge.estPaye == true;
    final primary =
        isPaid ? ChargeDetailAction.markUnpaid : ChargeDetailAction.markPaid;
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
              child: isPaid
                  ? OutlinedCustomButton(
                      text: 'Marquer impayée',
                      size: ButtonSize.md,
                      block: true,
                      loading: actionInProgress == primary,
                      textColor: AppColors.text2,
                      onPressed: disabled ? null : () => onAction(primary),
                    )
                  : CustomButton(
                      text: 'Marquer payée',
                      size: ButtonSize.md,
                      block: true,
                      loading: actionInProgress == primary,
                      onPressed: disabled ? null : () => onAction(primary),
                    ),
            ),
            const SizedBox(width: 10),
            IconBoutton(
              icon: Icons.edit_outlined,
              iconColor: AppColors.accent,
              onPressed: disabled
                  ? null
                  : () => onAction(ChargeDetailAction.edit),
            ),
            const SizedBox(width: 6),
            IconBoutton(
              icon: Icons.delete_outline,
              iconColor: AppColors.danger,
              onPressed: disabled
                  ? null
                  : () => onAction(ChargeDetailAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}
