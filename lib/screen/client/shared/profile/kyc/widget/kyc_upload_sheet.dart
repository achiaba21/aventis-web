import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asfar/screen/client/shared/profile/kyc/widget/kyc_title_selector.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/image_picker_util.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';

/// Bottom sheet d'envoi d'une pièce KYC : choix du titre, de la source photo
/// (galerie/caméra), aperçu, puis envoi via [onSubmit].
///
/// L'envoi réel (cubit) est délégué à l'écran parent via [onSubmit] (qui
/// retourne `true` en cas de succès) pour ne pas dépendre du provider dans le
/// contexte de la feuille. L'état d'upload est géré localement.
class KycUploadSheet extends StatefulWidget {
  final Future<bool> Function(File file, String titre) onSubmit;

  const KycUploadSheet({super.key, required this.onSubmit});

  @override
  State<KycUploadSheet> createState() => _KycUploadSheetState();
}

class _KycUploadSheetState extends State<KycUploadSheet> {
  String _titre = '';
  File? _photo;
  bool _submitting = false;

  Future<void> _pick(ImageSource source) async {
    final file = await ImagePickerUtil.pickImage(source: source);
    if (file != null && mounted) {
      setState(() => _photo = file);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    await widget.onSubmit(_photo!, _titre.trim());
    if (mounted) setState(() => _submitting = false);
  }

  bool get _canSubmit =>
      _titre.trim().isNotEmpty && _photo != null && !_submitting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        4,
        18,
        18 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Envoyer une pièce', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              'Choisissez le type de pièce et ajoutez une photo nette.',
              style: AppTextStyles.small.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 18),
            const Text('TYPE DE PIÈCE', style: AppTextStyles.eyebrow),
            const SizedBox(height: 10),
            KycTitleSelector(
              onChanged: (v) => setState(() => _titre = v),
            ),
            const SizedBox(height: 18),
            const Text('PHOTO', style: AppTextStyles.eyebrow),
            const SizedBox(height: 10),
            if (_photo != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.md),
                child: Image.file(
                  _photo!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Row(
              children: [
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_outlined,
                    label: _photo == null ? 'Galerie' : 'Changer',
                    onTap: _submitting
                        ? null
                        : () => _pick(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_camera_outlined,
                    label: 'Caméra',
                    onTap:
                        _submitting ? null : () => _pick(ImageSource.camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Envoyer',
              size: ButtonSize.lg,
              block: true,
              loading: _submitting,
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton de sélection de source photo (galerie / caméra). Privé à la sheet.
class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgElev2,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: AppColors.line, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.text2),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
