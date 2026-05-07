import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/input/input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget pour gérer les remises avec conditions
class DiscountManager extends StatefulWidget {
  const DiscountManager({
    super.key,
    this.remise,
    required this.onRemiseChanged,
  });

  final Remise? remise;
  final Function(Remise) onRemiseChanged;

  @override
  State<DiscountManager> createState() => _DiscountManagerState();
}

class _DiscountManagerState extends State<DiscountManager> {
  List<Condition> _conditions = [];

  @override
  void initState() {
    super.initState();
    if (widget.remise?.conditions != null) {
      _conditions = List.from(widget.remise!.conditions!);
    }
  }

  void _addCondition() {
    setState(() {
      _conditions.add(Condition(
        days: null,
        montant: null,
      ));
    });
    _updateRemise();
  }

  void _removeCondition(int index) {
    setState(() {
      _conditions.removeAt(index);
    });
    _updateRemise();
  }

  void _updateCondition(int index, {int? days, double? montant}) {
    setState(() {
      final condition = _conditions[index];
      _conditions[index] = Condition(
        id: condition.id,
        days: days ?? condition.days,
        montant: montant ?? condition.montant,
      );
    });
    _updateRemise();
  }

  void _updateRemise() {
    widget.onRemiseChanged(Remise(
      
      conditions: _conditions,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Liste des conditions existantes
        if (_conditions.isNotEmpty) ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _conditions.length,
            itemBuilder: (context, index) {
              return _buildConditionItem(index);
            },
          ),
          SizedBox(height: Espacement.gapSection),
        ],

        // Bouton pour ajouter une nouvelle condition
        OutlinedCustomButton(
          text: "Ajouter une condition de remise",
          onPressed: _addCondition,
          icon: Icons.add,
        ),

        if (_conditions.isEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: TextSeed(
              "Aucune remise configurée",
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
      ],
    );
  }

  Widget _buildConditionItem(int index) {
    final condition = _conditions[index];

    return Container(
      margin: EdgeInsets.only(bottom: Espacement.gapSection),
      padding: EdgeInsets.all(Espacement.paddingBloc / 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(Espacement.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextSeed(
                "Condition ${index + 1}",
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              ),
              IconButton(
                onPressed: () => _removeCondition(index),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: Espacement.gapSection / 2),
          Row(
            children: [
              Expanded(
                child: InputField(
                  libelle: "Nombre de jours minimum",
                  placeHolder: "7",
                  keyboardType: TextInputType.number,
                  initialValue: condition.days?.toString() ?? "",
                  onChange: (value) {
                    final days = int.tryParse(value ?? "0") ?? 0;
                    _updateCondition(index, days: days);
                  },
                ),
              ),
              SizedBox(width: Espacement.gapSection),
              Expanded(
                child: InputField(
                  libelle: "Nouveau prix (par nuit)",
                  placeHolder: "750.00",
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  initialValue: condition.montant?.toString() ?? "",
                  onChange: (value) {
                    final montant = double.tryParse(value ?? "0") ?? 0.0;
                    _updateCondition(index, montant: montant);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.accent),
                SizedBox(width: 8),
                Expanded(
                  child: TextSeed(
                    "Prix de ${condition.montant ?? 0} par nuit pour les réservations de ${condition.days ?? 0} jours ou plus",
                    fontSize: 12,
                    color: AppColors.background,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
