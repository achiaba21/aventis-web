import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Grid 2 colonnes de chips d'équipement multi-sélection — étape 4 wizard.
///
/// Reproduit `proprietaire-extras.jsx::AmenityChip` (lignes 461-472) :
/// chip padding 10×12 avec icon `check` si active sinon `add`, fond
/// `accentSoft`/`bgElev1`, border `accent`/`line`, color `accent`/`text`.
class AmenityChipGrid extends StatelessWidget {
  final String eyebrow;
  final List<String> amenities;
  final Set<String> active;
  final ValueChanged<String> onToggle;

  const AmenityChipGrid({
    super.key,
    required this.eyebrow,
    required this.amenities,
    required this.active,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(eyebrow.toUpperCase(), style: AppTextStyles.eyebrow),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 4.0,
          ),
          itemCount: amenities.length,
          itemBuilder: (_, i) {
            final amenity = amenities[i];
            return _AmenityChipItem(
              label: amenity,
              active: active.contains(amenity),
              onTap: () => onToggle(amenity),
            );
          },
        ),
      ],
    );
  }
}

class _AmenityChipItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _AmenityChipItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = active ? AppColors.accent : AppColors.text;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.accentSoft : AppColors.bgElev1,
            border: Border.all(
              color: active ? AppColors.accent : AppColors.line,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.check : Icons.add,
                size: 14,
                color: fg,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
