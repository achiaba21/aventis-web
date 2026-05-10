import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Ligne "champ d'affichage" du design Asfar Premium.
///
/// Eyebrow uppercase au-dessus + valeur en dessous + icon edit (ou
/// chevron) à droite. Utilisé dans Reserve étape 1, ListingEdit, etc.
class FieldRow extends StatelessWidget {
  final String eyebrow;
  final String value;
  final IconData trailingIcon;
  final VoidCallback? onTap;

  const FieldRow({
    super.key,
    required this.eyebrow,
    required this.value,
    this.trailingIcon = Icons.edit_outlined,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.line, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(eyebrow, style: AppTextStyles.eyebrow),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailingIcon, size: 16, color: AppColors.text3),
            ],
          ),
        ),
      ),
    );
  }
}
