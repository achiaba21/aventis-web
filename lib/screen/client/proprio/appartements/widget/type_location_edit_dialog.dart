import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Dialog picker pour modifier le type de logement depuis l'écran d'édition
/// d'une annonce. 5 options enum strictes (`AppartementTypeLocation`).
///
/// UX retenue (cf. business-spec / architecture §6.7) :
/// - Pattern `Dialog` aligné sur `CapacityEditDialog`.
/// - Sélection par radio + bouton Enregistrer (pas de tap-to-pop).
/// - Bouton Annuler retourne `null`.
class TypeLocationEditDialog extends StatefulWidget {
  final AppartementTypeLocation? initial;

  const TypeLocationEditDialog({super.key, this.initial});

  /// Helper d'ouverture. Renvoie le type choisi ou `null` si annulé.
  static Future<AppartementTypeLocation?> show(
    BuildContext context, {
    AppartementTypeLocation? initial,
  }) {
    return showDialog<AppartementTypeLocation>(
      context: context,
      builder: (_) => TypeLocationEditDialog(initial: initial),
    );
  }

  @override
  State<TypeLocationEditDialog> createState() => _TypeLocationEditDialogState();
}

class _TypeLocationEditDialogState extends State<TypeLocationEditDialog> {
  AppartementTypeLocation? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  void _onSave() {
    if (_selected == null) return;
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    final types = AppartementTypeLocation.values;
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
            Text('Type de logement', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Choisissez la typologie qui correspond le mieux à votre bien.',
              style: AppTextStyles.small.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 12),
            RadioGroup<AppartementTypeLocation>(
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final type in types)
                    RadioListTile<AppartementTypeLocation>(
                      value: type,
                      activeColor: AppColors.accent,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        type.label,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        type.description,
                        style: AppTextStyles.small.copyWith(
                          fontSize: 12,
                          color: AppColors.text3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Enregistrer',
              onPressed: _selected == null ? null : _onSave,
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
