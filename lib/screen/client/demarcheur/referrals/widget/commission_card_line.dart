import 'package:flutter/material.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Une ligne label/valeur du `CommissionCard`. Si `mono` est true, la valeur
/// utilise la police mono (sous-total).
class CommissionCardLine extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool mono;

  const CommissionCardLine({
    super.key,
    required this.label,
    required this.value,
    required this.valueColor,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontSize: 13, color: valueColor);
    final style = mono
        ? AppTextStyles.mono(base.copyWith(fontWeight: FontWeight.w600))
        : base.copyWith(fontWeight: FontWeight.w500);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.small),
        Text(value, style: style),
      ],
    );
  }
}
