import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/asfar_toggle.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/pricing_commission_preview.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Étape 5 du wizard — prix & conditions. Reproduit
/// `proprietaire-extras.jsx::step 5` (lignes 219-269).
class StepPricing extends StatelessWidget {
  final int? price;
  final Map<String, bool> rules;
  final ValueChanged<int?> onPriceChange;
  final void Function(String key, bool value) onRuleToggle;

  const StepPricing({
    super.key,
    required this.price,
    required this.rules,
    required this.onPriceChange,
    required this.onRuleToggle,
  });

  static const _rulesOrder = ['demarcheurs', 'caution', 'animaux'];
  static const _rulesLabels = {
    'demarcheurs': 'Accepter les démarcheurs (commission 10% sur séjour)',
    'caution': 'Caution remboursable',
    'animaux': 'Animaux acceptés',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prix & conditions', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Asfar prélève 8% par réservation. Vous gardez le reste.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        _PriceCard(price: price, onPriceChange: onPriceChange),
        const SizedBox(height: 14),
        const _CleaningFeePlaceholder(),
        const SizedBox(height: 14),
        _RulesCard(
          rules: rules,
          rulesOrder: _rulesOrder,
          rulesLabels: _rulesLabels,
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

  void _onChanged(String v) {
    final cleaned = v.replaceAll(RegExp(r'\D'), '');
    final int? parsed = cleaned.isEmpty ? null : int.tryParse(cleaned);
    widget.onPriceChange(parsed);
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
          Text('PRIX PAR NUIT', style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.number,
                  onChanged: _onChanged,
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  )),
                  decoration: InputDecoration(
                    hintText: '45 000',
                    hintStyle: AppTextStyles.mono(const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text3,
                    )),
                    filled: true,
                    fillColor: AppColors.bgElev2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide:
                          const BorderSide(color: AppColors.line, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide:
                          const BorderSide(color: AppColors.line, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      borderSide:
                          const BorderSide(color: AppColors.accent, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FCFA / nuit',
                style: TextStyle(fontSize: 14, color: AppColors.text3),
              ),
            ],
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

/// Frais de ménage : pas de champ dédié dans `Appartement` (V9.1 MVP).
/// Placeholder visuel proto-fidèle, donnée non persistée — à implémenter
/// quand le modèle backend expose un champ dédié.
class _CleaningFeePlaceholder extends StatelessWidget {
  const _CleaningFeePlaceholder();

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
          Text('FRAIS DE MÉNAGE (OPTIONNEL)', style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 14,
              color: AppColors.text,
            )),
            decoration: InputDecoration(
              hintText: '5 000',
              filled: true,
              fillColor: AppColors.bgElev2,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide:
                    const BorderSide(color: AppColors.line, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide:
                    const BorderSide(color: AppColors.line, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  final Map<String, bool> rules;
  final List<String> rulesOrder;
  final Map<String, String> rulesLabels;
  final void Function(String key, bool value) onToggle;

  const _RulesCard({
    required this.rules,
    required this.rulesOrder,
    required this.rulesLabels,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
          Text('RÈGLES', style: AppTextStyles.eyebrow),
          const SizedBox(height: 12),
          for (int i = 0; i < rulesOrder.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppColors.line, thickness: 1),
            _RuleRow(
              label: rulesLabels[rulesOrder[i]]!,
              value: rules[rulesOrder[i]] ?? false,
              onChanged: (v) => onToggle(rulesOrder[i], v),
            ),
          ],
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _RuleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AsfarToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
