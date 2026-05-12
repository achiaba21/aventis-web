import 'package:flutter/material.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Action bar sticky bottom de la page détail réservation.
///
/// - Si action `contact` présente : isolée à droite via `IconBoutton` phone.
/// - Première action restante : `CustomButton` primary block expanded.
/// - Actions restantes : `PopupMenuButton` overflow `⋯` (max 1-2 attendu).
/// - Si action en cours : bouton primary en loading + autres disabled.
class ReservationDetailActionsBar extends StatelessWidget {
  final List<ReservationDetailAction> actions;
  final ReservationDetailAction? actionInProgress;
  final void Function(ReservationDetailAction action) onAction;

  const ReservationDetailActionsBar({
    super.key,
    required this.actions,
    required this.onAction,
    this.actionInProgress,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (actions.isEmpty) {
      return SizedBox(height: 12 + mq.padding.bottom);
    }

    final hasContact = actions.contains(ReservationDetailAction.contact);
    final primaryActions = actions
        .where((a) => a != ReservationDetailAction.contact)
        .toList(growable: false);

    final primary = primaryActions.isNotEmpty ? primaryActions.first : null;
    final overflow = primaryActions.length > 1
        ? primaryActions.skip(1).toList(growable: false)
        : const <ReservationDetailAction>[];

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
            if (primary != null) ...[
              Expanded(child: _buildPrimary(primary, disabled)),
              if (hasContact || overflow.isNotEmpty) const SizedBox(width: 10),
            ] else if (hasContact) ...[
              Expanded(
                child: CustomButton(
                  text: 'Contacter',
                  size: ButtonSize.md,
                  block: true,
                  onPressed: disabled
                      ? null
                      : () => onAction(ReservationDetailAction.contact),
                ),
              ),
            ],
            if (primary != null && hasContact)
              IconBoutton(
                icon: Icons.phone_outlined,
                iconColor: AppColors.accent,
                onPressed: disabled
                    ? null
                    : () => onAction(ReservationDetailAction.contact),
              ),
            if (overflow.isNotEmpty) ...[
              const SizedBox(width: 6),
              _OverflowMenu(
                actions: overflow,
                disabled: disabled,
                onAction: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrimary(ReservationDetailAction action, bool disabled) {
    final loading = actionInProgress == action;
    final label = ReservationActionsResolver.labelOf(action);
    final isDestructive = action == ReservationDetailAction.cancel ||
        action == ReservationDetailAction.refuse;

    if (isDestructive) {
      return OutlinedCustomButton(
        text: label,
        size: ButtonSize.md,
        block: true,
        loading: loading,
        textColor: AppColors.danger,
        onPressed: disabled ? null : () => onAction(action),
      );
    }

    return CustomButton(
      text: label,
      size: ButtonSize.md,
      block: true,
      loading: loading,
      onPressed: disabled ? null : () => onAction(action),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  final List<ReservationDetailAction> actions;
  final bool disabled;
  final void Function(ReservationDetailAction action) onAction;

  const _OverflowMenu({
    required this.actions,
    required this.disabled,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ReservationDetailAction>(
      enabled: !disabled,
      icon: const Icon(Icons.more_horiz, color: AppColors.text2),
      color: AppColors.bgElev2,
      onSelected: onAction,
      itemBuilder: (_) => actions
          .map((a) => PopupMenuItem<ReservationDetailAction>(
                value: a,
                child: Text(
                  ReservationActionsResolver.labelOf(a),
                  style: const TextStyle(color: AppColors.text),
                ),
              ))
          .toList(),
    );
  }
}
