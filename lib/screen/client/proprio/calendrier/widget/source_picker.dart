import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Picker source de réservation manuelle — 2 RadioListTile.
///
/// `Client direct` (commission 0%) vs `Démarcheur partenaire` (commission 10%).
class SourcePicker extends StatelessWidget {
  final ReservationManuelleSource? value;
  final ValueChanged<ReservationManuelleSource?> onChanged;

  const SourcePicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: RadioGroup<ReservationManuelleSource>(
        groupValue: value,
        onChanged: onChanged,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < ReservationManuelleSource.values.length; i++) ...[
              RadioListTile<ReservationManuelleSource>(
                value: ReservationManuelleSource.values[i],
                activeColor: AppColors.accent,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                dense: true,
                title: Text(
                  ReservationManuelleSource.values[i].label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                subtitle: Text(
                  ReservationManuelleSource.values[i].description,
                  style: AppTextStyles.small.copyWith(
                    fontSize: 12,
                    color: AppColors.text3,
                  ),
                ),
              ),
              if (i < ReservationManuelleSource.values.length - 1)
                const Divider(height: 1, color: AppColors.line),
            ],
          ],
        ),
      ),
    );
  }
}
