import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card "Code de réservation" — eyebrow + code mono large.
///
/// Utilisé sur l'écran de confirmation pour afficher `ASF-7K2N9`.
class BookingCodeCard extends StatelessWidget {
  final String code;
  final String eyebrow;

  const BookingCodeCard({
    super.key,
    required this.code,
    this.eyebrow = 'CODE DE RÉSERVATION',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppTextStyles.eyebrow),
          const SizedBox(height: 8),
          Text(
            code,
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.text,
            )),
          ),
        ],
      ),
    );
  }
}
