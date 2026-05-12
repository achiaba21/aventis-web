import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Résultat retourné par `ChargePeriodPicker` : année + mois (0 = toute l'année).
class ChargePeriodResult {
  final int year;
  final int month;

  const ChargePeriodResult({required this.year, required this.month});
}

/// Bottom sheet de sélection période : année (chips) + mois (grille).
///
/// L'option "Toute l'année" est représentée par `month == 0`.
class ChargePeriodPicker {
  ChargePeriodPicker._();

  static Future<ChargePeriodResult?> show(
    BuildContext context, {
    required int year,
    required int month,
  }) {
    return showModalBottomSheet<ChargePeriodResult>(
      context: context,
      backgroundColor: AppColors.bgElev1,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      builder: (_) =>
          _ChargePeriodPickerBody(initialYear: year, initialMonth: month),
    );
  }
}

class _ChargePeriodPickerBody extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const _ChargePeriodPickerBody({
    required this.initialYear,
    required this.initialMonth,
  });

  @override
  State<_ChargePeriodPickerBody> createState() =>
      _ChargePeriodPickerBodyState();
}

class _ChargePeriodPickerBodyState extends State<_ChargePeriodPickerBody> {
  late int _year;
  late int _month;

  static const _monthLabels = [
    'Toute',
    'Janv', 'Févr', 'Mars', 'Avr', 'Mai', 'Juin',
    'Juil', 'Août', 'Sept', 'Oct', 'Nov', 'Déc',
  ];

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
    _month = widget.initialMonth;
  }

  void _confirm() {
    Navigator.of(context).pop(
      ChargePeriodResult(year: _year, month: _month),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final currentYear = DateTime.now().year;

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
              child: Text('PÉRIODE', style: AppTextStyles.eyebrow),
            ),
          ),
          const SizedBox(height: 14),
          _YearStepper(
            year: _year,
            canGoPrev: _year > currentYear - 10,
            canGoNext: _year < currentYear,
            onPrev: () => setState(() => _year--),
            onNext: () => setState(() => _year++),
          ),
          const SizedBox(height: 16),
          _MonthGrid(
            labels: _monthLabels,
            selected: _month,
            onSelect: (m) => setState(() => _month = m),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.onAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _confirm,
                child: const Text(
                  'Appliquer',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _YearStepper extends StatelessWidget {
  final int year;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _YearStepper({
    required this.year,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.bgElev2,
          border: Border.all(color: AppColors.line, width: 1),
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Row(
          children: [
            _StepperButton(
              icon: Icons.chevron_left,
              enabled: canGoPrev,
              onTap: onPrev,
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$year',
                  style: AppTextStyles.mono(const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  )),
                ),
              ),
            ),
            _StepperButton(
              icon: Icons.chevron_right,
              enabled: canGoNext,
              onTap: onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            icon,
            size: 22,
            color: enabled ? AppColors.text : AppColors.textDim,
          ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelect;

  const _MonthGrid({
    required this.labels,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(labels.length, (i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Container(
              width: (MediaQuery.of(context).size.width - 40 - 24) / 4,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? AppColors.accentSoft : AppColors.bgElev2,
                border: Border.all(
                  color: isSelected ? AppColors.accent : AppColors.line,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              alignment: Alignment.center,
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.accent : AppColors.text,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
