import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Résultat retourné par `CapacityEditDialog.show()`.
class CapacityResult {
  final int nbLits;
  final int nbChambres;
  final int nbDouches;

  const CapacityResult({
    required this.nbLits,
    required this.nbChambres,
    required this.nbDouches,
  });
}

/// Dialog d'édition de la capacité d'un logement — 3 champs numeric
/// (lits, chambres, salles de bain).
class CapacityEditDialog extends StatefulWidget {
  final int initialBeds;
  final int initialRooms;
  final int initialBaths;

  const CapacityEditDialog({
    super.key,
    required this.initialBeds,
    required this.initialRooms,
    required this.initialBaths,
  });

  /// Helper d'ouverture. Renvoie un `CapacityResult` ou `null` si annulé.
  static Future<CapacityResult?> show(
    BuildContext context, {
    required int initialBeds,
    required int initialRooms,
    required int initialBaths,
  }) {
    return showDialog<CapacityResult>(
      context: context,
      builder: (_) => CapacityEditDialog(
        initialBeds: initialBeds,
        initialRooms: initialRooms,
        initialBaths: initialBaths,
      ),
    );
  }

  @override
  State<CapacityEditDialog> createState() => _CapacityEditDialogState();
}

class _CapacityEditDialogState extends State<CapacityEditDialog> {
  late final TextEditingController _bedsCtrl;
  late final TextEditingController _roomsCtrl;
  late final TextEditingController _bathsCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bedsCtrl = TextEditingController(text: widget.initialBeds.toString());
    _roomsCtrl = TextEditingController(text: widget.initialRooms.toString());
    _bathsCtrl = TextEditingController(text: widget.initialBaths.toString());
  }

  @override
  void dispose() {
    _bedsCtrl.dispose();
    _roomsCtrl.dispose();
    _bathsCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    final beds = int.tryParse(_bedsCtrl.text.trim());
    final rooms = int.tryParse(_roomsCtrl.text.trim());
    final baths = int.tryParse(_bathsCtrl.text.trim());
    if (beds == null || beds < 0) {
      setState(() => _error = 'Nombre de lits invalide.');
      return;
    }
    if (rooms == null || rooms < 0) {
      setState(() => _error = 'Nombre de chambres invalide.');
      return;
    }
    if (baths == null || baths < 0) {
      setState(() => _error = 'Nombre de salles de bain invalide.');
      return;
    }
    Navigator.of(context).pop(
      CapacityResult(nbLits: beds, nbChambres: rooms, nbDouches: baths),
    );
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
            Text('Capacité', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Combien de voyageurs votre logement peut-il accueillir ?',
              style: AppTextStyles.small.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _bedsCtrl,
              eyebrow: 'NOMBRE DE LITS',
              hintText: '2',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            InputField(
              controller: _roomsCtrl,
              eyebrow: 'NOMBRE DE CHAMBRES',
              hintText: '1',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            InputField(
              controller: _bathsCtrl,
              eyebrow: 'SALLES DE BAIN',
              hintText: '1',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              text: 'Enregistrer',
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
