import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Dialog de saisie d'une période à bloquer (maintenance / perso).
///
/// 2 dates obligatoires (debut < fin). Au valide → retourne un `DateTimeRange`.
/// Au cancel → retourne `null`.
class BlockPeriodDialog extends StatefulWidget {
  const BlockPeriodDialog({super.key});

  static Future<DateTimeRange?> show(BuildContext context) {
    return showDialog<DateTimeRange>(
      context: context,
      builder: (_) => const BlockPeriodDialog(),
    );
  }

  @override
  State<BlockPeriodDialog> createState() => _BlockPeriodDialogState();
}

class _BlockPeriodDialogState extends State<BlockPeriodDialog> {
  DateTime? _debut;
  DateTime? _fin;
  String? _error;

  Future<void> _pickDate({required bool isDebut}) async {
    final now = DateTime.now();
    final initial = isDebut
        ? (_debut ?? now)
        : (_fin ?? (_debut ?? now).add(const Duration(days: 1)));
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) {
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: AppColors.onAccent,
              surface: AppColors.bgElev1,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (result == null) return;
    setState(() {
      if (isDebut) {
        _debut = result;
        if (_fin != null && !_fin!.isAfter(result)) {
          _fin = result.add(const Duration(days: 1));
        }
      } else {
        _fin = result;
      }
      _error = null;
    });
  }

  void _onSave() {
    if (_debut == null || _fin == null) {
      setState(() => _error = 'Veuillez sélectionner les deux dates.');
      return;
    }
    if (!_fin!.isAfter(_debut!)) {
      setState(() => _error = 'La date de fin doit être après le début.');
      return;
    }
    Navigator.of(context).pop(DateTimeRange(start: _debut!, end: _fin!));
  }

  String _format(DateTime? d) {
    if (d == null) return 'Sélectionner';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgElev1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Bloquer une période', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Maintenance, séjour personnel, ou indisponibilité temporaire.',
              style: AppTextStyles.small.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),
            _DateField(
              label: 'DÉBUT',
              value: _format(_debut),
              onTap: () => _pickDate(isDebut: true),
            ),
            const SizedBox(height: 10),
            _DateField(
              label: 'FIN',
              value: _format(_fin),
              onTap: () => _pickDate(isDebut: false),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: AppTextStyles.small.copyWith(
                  fontSize: 12,
                  color: AppColors.danger,
                ),
              ),
            ],
            const SizedBox(height: 18),
            CustomButton(
              text: 'Bloquer',
              onPressed: _onSave,
              size: ButtonSize.lg,
              block: true,
            ),
            const SizedBox(height: 8),
            OutlinedCustomButton(
              text: 'Annuler',
              onPressed: () => Navigator.of(context).pop(),
              size: ButtonSize.md,
              block: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgElev2,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: AppTextStyles.eyebrow),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 14,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_month_outlined,
              size: 18,
              color: AppColors.text3,
            ),
          ],
        ),
      ),
    );
  }
}
