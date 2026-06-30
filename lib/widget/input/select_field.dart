import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Champ « sélecteur » du design system : visuellement aligné sur `InputField`
/// (fond `bgElev2`, border `line`/`danger`, radius `md`) mais en lecture seule,
/// ouvert au tap.
///
/// Contrairement à un `InputField(readOnly, hintText: valeur)`, la valeur
/// choisie s'affiche en **texte plein** (couleur `text`) ; le [placeholder]
/// pâle (`text3`) n'apparaît que tant que [value] est nul/vide. Un chevron ▾
/// signale l'action.
class SelectField extends StatelessWidget {
  /// Texte affiché tant qu'aucune valeur n'est choisie.
  final String placeholder;

  /// Valeur sélectionnée (null/vide → [placeholder]).
  final String? value;

  /// Icône Material à gauche (ignorée si [leadingEmoji] est fourni).
  final IconData? leadingIcon;

  /// Emoji à gauche (prioritaire sur [leadingIcon]) — ex. icône de type.
  final String? leadingEmoji;

  /// Message d'erreur sous le champ ; la bordure passe alors en `danger`.
  final String? errorText;

  final VoidCallback? onTap;

  const SelectField({
    super.key,
    required this.placeholder,
    this.value,
    this.leadingIcon,
    this.leadingEmoji,
    this.errorText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.trim().isNotEmpty;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? AppColors.danger : AppColors.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bgElev2,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  if (leadingEmoji != null) ...[
                    Text(leadingEmoji!, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                  ] else if (leadingIcon != null) ...[
                    Icon(leadingIcon, size: 18, color: AppColors.text3),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      hasValue ? value! : placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        color: hasValue ? AppColors.text : AppColors.text3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 18, color: AppColors.text3),
                ],
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: AppTextStyles.small.copyWith(color: AppColors.danger),
          ),
        ],
      ],
    );
  }
}
