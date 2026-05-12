import 'package:flutter/material.dart';
import 'package:asfar/bloc/charge_filter_cubit/charge_filter_cubit.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charges/widget/charge_statut_filter_chips.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Barre de filtres complète : chips statut + 3 boutons (appart/type/période).
///
/// Les pickers (appart/type/période) sont déclenchés par le caller via les
/// callbacks pour garder ce widget découplé du contexte BLoC.
class ChargeFilterBar extends StatelessWidget {
  final ChargeFilterState state;
  final ValueChanged<ChargeStatutFilter> onStatutChange;
  final VoidCallback onTapAppart;
  final VoidCallback onTapType;
  final VoidCallback onTapPeriod;
  final String appartLabel;
  final String periodLabel;

  const ChargeFilterBar({
    super.key,
    required this.state,
    required this.onStatutChange,
    required this.onTapAppart,
    required this.onTapType,
    required this.onTapPeriod,
    required this.appartLabel,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 6),
        ChargeStatutFilterChips(
          selected: state.statut,
          onSelect: onStatutChange,
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            children: [
              _FilterPillButton(
                icon: Icons.home_outlined,
                label: appartLabel,
                active: state.appartementId != null,
                onTap: onTapAppart,
              ),
              const SizedBox(width: 8),
              _FilterPillButton(
                icon: Icons.category_outlined,
                label: state.typeCharge?.label ?? 'Type',
                active: state.typeCharge != null,
                onTap: onTapType,
              ),
              const SizedBox(width: 8),
              _FilterPillButton(
                icon: Icons.calendar_today_outlined,
                label: periodLabel,
                active: state.month != 0,
                onTap: onTapPeriod,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterPillButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? AppColors.accent : AppColors.text2;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.accentSoft : AppColors.bgElev2,
            border: Border.all(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.3)
                  : AppColors.line,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  fontSize: 13,
                  color: fg,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.expand_more, size: 14, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}
