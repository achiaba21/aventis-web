import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Row de 3 status pills statistiques — Dashboard démarcheur.
///
/// Reproduit le proto `demarcheur.jsx::DemarcheurDashboard` (lignes 93-107) :
/// 3 cards `bgElev1` border `line` radius `lg` flex 1, padding 14, valeur
/// mono 22 px bold + label small 11 px. La couleur de la valeur est
/// configurée par item (warn pour « En attente », success pour « Acceptées »,
/// neutre pour « Taux acceptation »).
class StatusPillsRow extends StatelessWidget {
  final List<StatusPillItem> items;

  const StatusPillsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(child: _pill(items[i])),
          if (i != items.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }

  Widget _pill(StatusPillItem item) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        children: [
          Text(
            item.value,
            style: AppTextStyles.mono(TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: item.valueColor ?? AppColors.text,
            )),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: AppTextStyles.small.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class StatusPillItem {
  final String value;
  final String label;
  final Color? valueColor;

  const StatusPillItem({
    required this.value,
    required this.label,
    this.valueColor,
  });
}
