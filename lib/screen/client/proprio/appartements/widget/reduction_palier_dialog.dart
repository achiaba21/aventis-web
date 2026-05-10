import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Résultat retourné par `ReductionPalierDialog.show()`.
///
/// - `condition == null` && `delete == true` → suppression demandée
/// - `condition != null` → création ou édition (selon contexte appelant)
/// - dialog annulé → renvoie null (pas un `PalierDialogResult`)
class PalierDialogResult {
  final Condition? condition;
  final bool delete;

  const PalierDialogResult({this.condition, this.delete = false});
}

/// Dialog d'édition d'un palier de réduction (`Condition`).
///
/// V9.2 : 2 champs (seuil en nuits, montant en %), validation simple.
/// Mode édition affiche en plus un bouton "Supprimer" (renvoyant
/// `delete: true`).
class ReductionPalierDialog extends StatefulWidget {
  final Condition? initial;

  const ReductionPalierDialog({super.key, this.initial});

  /// Helper d'ouverture. Renvoie `null` si annulé, sinon un
  /// `PalierDialogResult`.
  static Future<PalierDialogResult?> show(
    BuildContext context, {
    Condition? initial,
  }) {
    return showDialog<PalierDialogResult>(
      context: context,
      builder: (_) => ReductionPalierDialog(initial: initial),
    );
  }

  @override
  State<ReductionPalierDialog> createState() => _ReductionPalierDialogState();
}

class _ReductionPalierDialogState extends State<ReductionPalierDialog> {
  late final TextEditingController _daysCtrl;
  late final TextEditingController _montantCtrl;
  String? _error;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    _daysCtrl = TextEditingController(
      text: widget.initial?.days?.toString() ?? '',
    );
    _montantCtrl = TextEditingController(
      text: widget.initial?.montant != null
          ? widget.initial!.montant!.toStringAsFixed(0)
          : '',
    );
  }

  @override
  void dispose() {
    _daysCtrl.dispose();
    _montantCtrl.dispose();
    super.dispose();
  }

  void _onSave() {
    final daysText = _daysCtrl.text.trim();
    final montantText = _montantCtrl.text.trim();
    final days = int.tryParse(daysText);
    final montant = double.tryParse(montantText);
    if (days == null || days <= 0) {
      setState(() => _error = 'Saisissez un nombre de nuits positif.');
      return;
    }
    if (montant == null || montant <= 0) {
      setState(() => _error = 'Saisissez un prix journalier positif.');
      return;
    }
    Navigator.of(context).pop(
      PalierDialogResult(
        condition: Condition(
          id: widget.initial?.id,
          days: days,
          montant: montant,
        ),
      ),
    );
  }

  void _onDelete() {
    Navigator.of(context).pop(const PalierDialogResult(delete: true));
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
            Text(
              _isEditing ? 'Modifier le palier' : 'Nouveau palier',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 4),
            Text(
              _isEditing
                  ? 'Ajustez le seuil de nuits ou le prix journalier appliqué.'
                  : 'À partir d\'un certain nombre de nuits, applique un prix journalier réduit.',
              style: AppTextStyles.small.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _daysCtrl,
              eyebrow: 'À PARTIR DE (NUITS)',
              hintText: '7',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),
            InputField(
              controller: _montantCtrl,
              eyebrow: 'NOUVEAU PRIX / NUIT (FCFA)',
              hintText: '40000',
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
              text: _isEditing ? 'Enregistrer' : 'Ajouter',
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
            if (_isEditing) ...[
              const SizedBox(height: 4),
              PlainButton(
                text: 'Supprimer ce palier',
                onPressed: _onDelete,
                size: ButtonSize.md,
                block: true,
                textColor: AppColors.danger,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
