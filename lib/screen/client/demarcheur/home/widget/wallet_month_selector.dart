import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Sélecteur de mois affiché dans la `WalletHeroCard` du dashboard démarcheur.
///
/// Format : `‹ MAI 2026 ›`. Le chevron droit (`onNext`) est désactivé
/// visuellement quand `onNext == null` — on ne dépasse jamais le mois courant.
class WalletMonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const WalletMonthSelector({
    super.key,
    required this.label,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChevronButton(
          icon: Icons.chevron_left,
          onTap: onPrev,
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.eyebrow.copyWith(
            color: AppColors.walletBlueAccent,
          ),
        ),
        const SizedBox(width: 8),
        _ChevronButton(
          icon: Icons.chevron_right,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _ChevronButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _ChevronButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkResponse(
      onTap: onTap,
      radius: 18,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.walletBlueAccent
              .withValues(alpha: enabled ? 1.0 : 0.3),
        ),
      ),
    );
  }
}
