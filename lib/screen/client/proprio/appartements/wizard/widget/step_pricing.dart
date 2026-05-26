import 'package:flutter/material.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/pricing_commission_preview.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/wizard_remises_card.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/wizard_rules_card.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/input/number_input_field.dart';

/// Étape 5 du wizard — prix & conditions.
///
/// 3 sections :
/// - Prix par nuit + preview commission (taux backend dynamique)
/// - Remises long séjour (paliers, optionnels)
/// - Règles de la maison (référentiel backend `GET /auth/rules`)
class StepPricing extends StatelessWidget {
  final int? price;

  /// Sélection des règles par `ruleId → allowed`.
  final Map<int, bool> rulesByRuleId;
  final List<Condition> remises;
  final ValueChanged<int?> onPriceChange;
  final void Function(int ruleId, bool allowed) onRuleToggle;
  final void Function(Condition added) onRemiseAdd;
  final void Function(Condition oldValue, Condition newValue) onRemiseUpdate;
  final void Function(Condition removed) onRemiseDelete;

  const StepPricing({
    super.key,
    required this.price,
    required this.rulesByRuleId,
    required this.remises,
    required this.onPriceChange,
    required this.onRuleToggle,
    required this.onRemiseAdd,
    required this.onRemiseUpdate,
    required this.onRemiseDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prix & conditions', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Le taux Asfar est affiché en preview. Vous gardez le reste.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        _PriceCard(price: price, onPriceChange: onPriceChange),
        const SizedBox(height: 14),
        WizardRemisesCard(
          conditions: remises,
          onAdd: onRemiseAdd,
          onUpdate: onRemiseUpdate,
          onDelete: onRemiseDelete,
        ),
        const SizedBox(height: 14),
        WizardRulesCard(
          rulesByRuleId: rulesByRuleId,
          onToggle: onRuleToggle,
        ),
      ],
    );
  }
}

class _PriceCard extends StatefulWidget {
  final int? price;
  final ValueChanged<int?> onPriceChange;

  const _PriceCard({required this.price, required this.onPriceChange});

  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.price?.toString() ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          NumberInputField(
            controller: _ctrl,
            eyebrow: 'PRIX PAR NUIT',
            hintText: '45 000',
            formatThousands: true,
            suffix: 'FCFA / nuit',
            textStyle: AppTextStyles.mono(const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            )),
            onChanged: widget.onPriceChange,
          ),
          if (widget.price != null && widget.price! > 0) ...[
            const SizedBox(height: 14),
            PricingCommissionPreview(pricePerNight: widget.price!),
          ],
        ],
      ),
    );
  }
}
