import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card de récap post-confirmation : 3+ lignes (label small + valeur bold).
class BookingRecapCard extends StatelessWidget {
  final List<RecapLine> lines;

  const BookingRecapCard({super.key, required this.lines});

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
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lines[i].label, style: AppTextStyles.small),
                Text(
                  lines[i].value,
                  style: lines[i].mono
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
            ),
            if (i < lines.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

/// Une ligne du [BookingRecapCard].
class RecapLine {
  final String label;
  final String value;
  final bool mono;

  const RecapLine({
    required this.label,
    required this.value,
    this.mono = false,
  });
}
