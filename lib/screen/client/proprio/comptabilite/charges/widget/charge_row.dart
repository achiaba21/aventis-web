import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/charge_status_display.dart';
import 'package:asfar/util/fcfa_formatter.dart';
import 'package:asfar/widget/badge/badge_status.dart';

/// Carte d'une charge dans la liste, swipeable pour marquer payée/impayée.
///
/// `Dismissible` direction `startToEnd` : background success (→ marquer payée)
/// si non payée, neutre (→ marquer impayée) si payée. `confirmDismiss` retourne
/// `false` pour laisser le `ChargeBloc` piloter le re-render via `RefreshCharges`.
class ChargeRow extends StatelessWidget {
  final Charge charge;
  final VoidCallback? onTap;
  final Future<bool> Function(Charge charge)? onSwipeAction;

  const ChargeRow({
    super.key,
    required this.charge,
    this.onTap,
    this.onSwipeAction,
  });

  static const _months = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day} ${_months[dt.month - 1]}';
  }

  String _subLine() {
    final appart = charge.appartementNom?.trim();
    final isPaid = charge.estPaye == true;
    final pivot = isPaid ? charge.datePaiement : charge.dateEcheance;
    final pivotLabel = isPaid ? 'Payée' : 'Éch.';
    final dateText = pivot != null ? '$pivotLabel ${_formatDate(pivot)}' : '';
    if ((appart == null || appart.isEmpty) && dateText.isEmpty) return '';
    if (appart == null || appart.isEmpty) return dateText;
    if (dateText.isEmpty) return appart;
    return '$appart · $dateText';
  }

  @override
  Widget build(BuildContext context) {
    final statut = ChargeStatusDisplay.statutOf(charge);
    final isPaid = charge.estPaye == true;
    final montant = (charge.montant ?? 0).round();

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            border: Border.all(color: AppColors.line, width: 1),
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            children: [
              _ChargeTypeIcon(typeIcon: charge.typeCharge.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            charge.labelComplet,
                            style: AppTextStyles.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FcfaFormatter.full(montant),
                          style: AppTextStyles.mono(TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isPaid ? AppColors.text2 : AppColors.accent,
                          )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subLine(),
                      style: AppTextStyles.small.copyWith(
                        fontSize: 12,
                        color: AppColors.text3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    BadgeStatus(
                      text: ChargeStatusDisplay.labelOf(statut),
                      tone: ChargeStatusDisplay.toneOf(statut),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onSwipeAction == null) return card;

    return Dismissible(
      key: ValueKey('charge_${charge.id}'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        await onSwipeAction!(charge);
        return false;
      },
      background: _ChargeSwipeBackground(isPaid: isPaid),
      child: card,
    );
  }
}

class _ChargeTypeIcon extends StatelessWidget {
  final String typeIcon;

  const _ChargeTypeIcon({required this.typeIcon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.accentSoft,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(typeIcon, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _ChargeSwipeBackground extends StatelessWidget {
  final bool isPaid;

  const _ChargeSwipeBackground({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: isPaid ? AppColors.bgElev3 : AppColors.success,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPaid ? Icons.undo_rounded : Icons.check_circle_outline,
            color: AppColors.text,
            size: 22,
          ),
          const SizedBox(width: 10),
          Text(
            isPaid ? 'Marquer impayée' : 'Marquer payée',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
