import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Une ligne label/value du récap de demande envoyée (étape 3 du tunnel
/// `NewReferralScreen`). Si `mono` est true, la valeur utilise la police
/// mono bold (référence générée).
class RecapLine extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const RecapLine({
    super.key,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.small),
        Text(
          value,
          style: mono
              ? AppTextStyles.mono(const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ))
              : const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
        ),
      ],
    );
  }
}
