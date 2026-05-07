import 'package:flutter/material.dart';
import 'package:asfar/model/phone/phone_number.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/input/phone_input_field.dart';
import 'package:asfar/widget/text/text_seed.dart';

class EnvoyerDemandeForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String telephone) onSend;

  const EnvoyerDemandeForm({
    super.key,
    required this.isLoading,
    required this.onSend,
  });

  @override
  State<EnvoyerDemandeForm> createState() => _EnvoyerDemandeFormState();
}

class _EnvoyerDemandeFormState extends State<EnvoyerDemandeForm> {
  PhoneNumber? _phone;

  void _submit() {
    if (_phone == null || !_phone!.isValid) return;
    widget.onSend(_phone!.internationalFormat);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextSeed(
            'Envoyer une demande',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          PhoneInputField(
            libelle: 'Numéro du propriétaire',
            onPhoneChanged: (phone) => _phone = phone,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textOnAccent,
                      ),
                    )
                  : const Text(
                      'Envoyer la demande',
                      style: TextStyle(color: AppColors.textOnAccent),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
