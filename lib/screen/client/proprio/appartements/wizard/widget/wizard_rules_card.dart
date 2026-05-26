import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/rule_cubit/rule_cubit.dart';
import 'package:asfar/model/residence/rule.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/asfar_toggle.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/icon_mapper.dart';

/// Card « Règles » du step 5 wizard, alimentée par `RuleCubit` (référentiel
/// backend `GET /auth/rules`).
///
/// Pour chaque règle du référentiel, affiche un toggle dont la valeur initiale
/// vient de `defaultAllowed`. La sélection effective est conservée par le
/// caller dans une `Map<int ruleId, bool allowed>`.
class WizardRulesCard extends StatelessWidget {
  /// Map `ruleId → allowed` portant la sélection effective.
  final Map<int, bool> rulesByRuleId;

  /// Callback appelé au toggle d'une règle (avec `ruleId` et la nouvelle valeur).
  final void Function(int ruleId, bool allowed) onToggle;

  const WizardRulesCard({
    super.key,
    required this.rulesByRuleId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RuleCubit, RuleState>(
      builder: (context, state) {
        final rules = state.rules;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgElev1,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.line, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('RÈGLES DE LA MAISON', style: AppTextStyles.eyebrow),
              const SizedBox(height: 6),
              Text(
                'Définissez ce qui est autorisé ou non dans votre logement.',
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  color: AppColors.text3,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              if (state.isLoading && rules.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                )
              else if (rules.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Référentiel indisponible. Réessayez plus tard.',
                    style: AppTextStyles.small.copyWith(
                      fontSize: 12,
                      color: AppColors.text3,
                    ),
                  ),
                )
              else
                for (var i = 0; i < rules.length; i++) ...[
                  if (i > 0)
                    const Divider(
                        height: 1, color: AppColors.line, thickness: 1),
                  _RuleRow(
                    rule: rules[i],
                    allowed: _allowedFor(rules[i]),
                    onChanged: (v) {
                      final id = rules[i].id;
                      if (id != null) onToggle(id, v);
                    },
                  ),
                ],
            ],
          ),
        );
      },
    );
  }

  /// Valeur effective pour la règle : si déjà choisie dans `rulesByRuleId`,
  /// on retourne celle-là ; sinon on retombe sur `defaultAllowed` du référentiel.
  bool _allowedFor(Rule rule) {
    final id = rule.id;
    if (id != null && rulesByRuleId.containsKey(id)) {
      return rulesByRuleId[id]!;
    }
    return rule.defaultAllowed ?? false;
  }
}

class _RuleRow extends StatelessWidget {
  final Rule rule;
  final bool allowed;
  final ValueChanged<bool> onChanged;

  const _RuleRow({
    required this.rule,
    required this.allowed,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final icon = IconMapper.getIcon(rule.iconName);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.text2),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              rule.text ?? '—',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AsfarToggle(value: allowed, onChanged: onChanged),
        ],
      ),
    );
  }
}
