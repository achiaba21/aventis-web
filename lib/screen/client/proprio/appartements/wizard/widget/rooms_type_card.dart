import 'package:flutter/material.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Card sélectionnable pour le choix du type de logement — étape 1 wizard.
///
/// Lit directement `label` et `description` depuis [AppartementTypeLocation]
/// pour garantir la cohérence avec le picker d'édition.
class RoomsTypeCard extends StatelessWidget {
  final AppartementTypeLocation type;
  final bool active;
  final VoidCallback onTap;

  const RoomsTypeCard({
    super.key,
    required this.type,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? AppColors.accent : AppColors.text;
    final Color borderColor = active ? AppColors.accent : AppColors.line;
    final Color bg = active ? AppColors.accentSoft : AppColors.bgElev1;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type.label,
                style: AppTextStyles.mono(TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  height: 1,
                )),
              ),
              const SizedBox(height: 6),
              Text(
                type.description,
                style: AppTextStyles.small.copyWith(
                  fontSize: 11,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
