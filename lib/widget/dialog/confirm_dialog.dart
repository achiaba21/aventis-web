import 'package:flutter/material.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget de dialogue de confirmation réutilisable
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    this.content,
    required this.confirmText,
    this.cancelText = "Annuler",
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.isDangerous = false,
  });

  final String title;
  final String? content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final bool isDangerous; // Si true, bouton rouge

  @override
  Widget build(BuildContext context) {
    final buttonColor = isDangerous
        ? AppColors.error
        : (confirmColor ?? AppColors.accent);

    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: TextSeed(
        title,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      content: content != null
          ? TextSeed(
              content!,
              fontSize: 14,
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            )
          : null,
      actions: [
        TextButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            } else {
              Navigator.pop(context, false);
            }
          },
          child: TextSeed(
            cancelText,
            color: AppColors.textPrimary.withValues(alpha: 0.7),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (onConfirm != null) {
              onConfirm!();
            } else {
              Navigator.pop(context, true);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: TextSeed(
            confirmText,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Affiche le dialogue et retourne true si confirmé, false sinon
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? content,
    required String confirmText,
    String cancelText = "Annuler",
    Color? confirmColor,
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        isDangerous: isDangerous,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );
    return result ?? false;
  }
}
