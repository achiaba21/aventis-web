import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';
import 'package:asfar/widget/input/phone_input_field.dart';

/// Dialog d'envoi d'une demande de partenariat — 1 champ téléphone du
/// propriétaire ciblé.
class SendDemandeDialog extends StatefulWidget {
  const SendDemandeDialog({super.key});

  /// Helper d'ouverture. Renvoie le téléphone trim, ou `null` si annulé.
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const SendDemandeDialog(),
    );
  }

  @override
  State<SendDemandeDialog> createState() => _SendDemandeDialogState();
}

class _SendDemandeDialogState extends State<SendDemandeDialog> {
  final _phoneCtrl = TextEditingController();
  String _fullPhone = '';
  String? _error;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final digits = _fullPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 11) {
      setState(() => _error = 'Saisissez un numéro de téléphone valide.');
      return;
    }
    Navigator.of(context).pop(_fullPhone);
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
            Text('Nouvelle demande', style: AppTextStyles.h3),
            const SizedBox(height: 4),
            Text(
              'Le propriétaire recevra votre demande de partenariat. Il pourra accepter ou refuser.',
              style: AppTextStyles.small.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 16),
            PhoneInputField(
              controller: _phoneCtrl,
              eyebrow: 'TÉLÉPHONE DU PROPRIÉTAIRE',
              errorText: _error,
              onChanged: (full) {
                _fullPhone = full;
                if (_error != null) setState(() => _error = null);
              },
            ),
            const SizedBox(height: 18),
            CustomButton(
              text: 'Envoyer',
              onPressed: _onSubmit,
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
