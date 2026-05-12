import 'package:flutter/material.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Bottom sheet de sélection d'une fréquence (utilisée dans le formulaire
/// de création/édition d'une charge).
class ChargeFrequencePicker {
  ChargeFrequencePicker._();

  static Future<FrequenceCharge?> show(
    BuildContext context, {
    required FrequenceCharge selected,
  }) {
    return showModalBottomSheet<FrequenceCharge>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) => _ChargeFrequencePickerBody(selected: selected),
    );
  }
}

class _ChargeFrequencePickerBody extends StatelessWidget {
  final FrequenceCharge selected;

  const _ChargeFrequencePickerBody({required this.selected});

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: mq.padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 14),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textDim,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('FRÉQUENCE', style: AppTextStyles.eyebrow),
            ),
          ),
          const SizedBox(height: 10),
          ...FrequenceCharge.values.map((f) => _FrequenceTile(
                label: f.label,
                selected: selected == f,
                onTap: () => Navigator.of(context).pop(f),
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FrequenceTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FrequenceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.line, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
