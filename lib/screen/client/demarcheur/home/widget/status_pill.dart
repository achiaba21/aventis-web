import 'package:flutter/material.dart';
import 'package:asfar/screen/client/demarcheur/home/widget/status_pills_row.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Une pill individuelle de la `StatusPillsRow` — valeur mono 22px +
/// label small 11px centré.
class StatusPill extends StatelessWidget {
  final StatusPillItem item;

  const StatusPill({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
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
