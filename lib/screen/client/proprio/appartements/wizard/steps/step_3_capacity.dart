import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/widget/wizard/capacity_pill_selector.dart';

/// Étape 3 du wizard : nombre de chambres (pills) + lits & douches (steppers).
class Step3Capacity extends StatelessWidget {
  const Step3Capacity({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppartementWizardBloc, AppartementWizardState>(
      buildWhen: (prev, next) =>
          prev.draft.nbChambres != next.draft.nbChambres ||
          prev.draft.nbLits != next.draft.nbLits ||
          prev.draft.nbDouches != next.draft.nbDouches,
      builder: (context, state) {
        final draft = state.draft;
        final bloc = context.read<AppartementWizardBloc>();

        return SingleChildScrollView(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextSeed(
                "Capacité",
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: Espacement.gapItem),
              TextSeed(
                "Combien de personnes pouvez-vous accueillir ?",
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: Espacement.gapSection * 2),
              _CapacityRow(
                icon: Icons.bed_outlined,
                label: "Chambres",
                value: draft.nbChambres ?? 0,
                builder: (value) => CapacityPillSelector(
                  value: value,
                  onChanged: (n) => bloc.add(UpdateField('nbChambres', n)),
                ),
              ),
              SizedBox(height: Espacement.gapSection * 2),
              _CapacityRow(
                icon: Icons.single_bed_outlined,
                label: "Lits",
                value: draft.nbLits ?? 0,
                builder: (value) => _Stepper(
                  value: value,
                  onChanged: (n) => bloc.add(UpdateField('nbLits', n)),
                ),
              ),
              SizedBox(height: Espacement.gapSection * 2),
              _CapacityRow(
                icon: Icons.bathroom_outlined,
                label: "Salles d'eau",
                value: draft.nbDouches ?? 0,
                builder: (value) => _Stepper(
                  value: value,
                  onChanged: (n) => bloc.add(UpdateField('nbDouches', n)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CapacityRow extends StatelessWidget {
  const _CapacityRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.builder,
  });

  final IconData icon;
  final String label;
  final int value;
  final Widget Function(int value) builder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 20),
            SizedBox(width: Espacement.gapItem),
            TextSeed(
              label,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        SizedBox(height: Espacement.gapSection),
        builder(value),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.value,
    required this.onChanged,
  });

  static const int _minValue = 0;
  static const int _maxValue = 20;

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > _minValue;
    final canIncrement = value < _maxValue;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Espacement.paddingBloc,
        vertical: Espacement.paddingInput,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepperButton(
            icon: Icons.remove,
            enabled: canDecrement,
            onTap: () => onChanged(value - 1),
          ),
          TextSeed(
            value.toString(),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          _StepperButton(
            icon: Icons.add,
            enabled: canIncrement,
            onTap: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.accent : AppColors.textMuted;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(Espacement.circle),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
