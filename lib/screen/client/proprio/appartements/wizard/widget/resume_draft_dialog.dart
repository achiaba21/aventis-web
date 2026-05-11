import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Dialog "Reprendre votre brouillon ?" affiché à l'ouverture du wizard
/// d'ajout d'appartement quand un draft Hive existe.
///
/// Retourne `true` si l'utilisateur tape "Reprendre", `false` si "Recommencer",
/// `null` si dismiss (back button) — l'appelant doit alors traiter comme
/// `false` (recommencer) ou ré-afficher.
class ResumeDraftDialog extends StatelessWidget {
  const ResumeDraftDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ResumeDraftDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgElev1,
      surfaceTintColor: AppColors.bgElev1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        side: const BorderSide(color: AppColors.line, width: 1),
      ),
      title: const Text(
        'Création en cours',
        style: AppTextStyles.h3,
      ),
      content: Text(
        'Vous avez une annonce en cours de création. '
        'Reprendre où vous en étiez ?',
        style: AppTextStyles.body,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedCustomButton(
                text: 'Recommencer',
                onPressed: () => Navigator.of(context).pop(false),
                size: ButtonSize.md,
                block: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: 'Reprendre',
                onPressed: () => Navigator.of(context).pop(true),
                size: ButtonSize.md,
                block: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
