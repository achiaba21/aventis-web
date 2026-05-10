import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/input/input_field.dart';

/// Dialog réutilisable pour éditer un champ texte d'une annonce
/// (titre, description, type, regles, etc.).
///
/// V9.3 — pattern unifié pour les éditions string. Renvoie le nouveau
/// texte trimé, ou `null` si annulé.
class TextFieldEditDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String fieldLabel;
  final String? initialValue;
  final String? hintText;
  final int maxLines;
  final bool required;

  const TextFieldEditDialog({
    super.key,
    required this.title,
    required this.fieldLabel,
    this.subtitle,
    this.initialValue,
    this.hintText,
    this.maxLines = 1,
    this.required = true,
  });

  /// Helper d'ouverture. Renvoie le texte saisi (trim) ou `null` si annulé.
  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String fieldLabel,
    String? subtitle,
    String? initialValue,
    String? hintText,
    int maxLines = 1,
    bool required = true,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => TextFieldEditDialog(
        title: title,
        fieldLabel: fieldLabel,
        subtitle: subtitle,
        initialValue: initialValue,
        hintText: hintText,
        maxLines: maxLines,
        required: required,
      ),
    );
  }

  @override
  State<TextFieldEditDialog> createState() => _TextFieldEditDialogState();
}

class _TextFieldEditDialogState extends State<TextFieldEditDialog> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onSave() {
    final value = _ctrl.text.trim();
    if (widget.required && value.isEmpty) {
      setState(() => _error = 'Ce champ ne peut pas être vide.');
      return;
    }
    Navigator.of(context).pop(value);
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
            Text(widget.title, style: AppTextStyles.h3),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                style: AppTextStyles.small.copyWith(fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            InputField(
              controller: _ctrl,
              eyebrow: widget.fieldLabel,
              hintText: widget.hintText,
              maxLines: widget.maxLines,
              autofocus: true,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
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
