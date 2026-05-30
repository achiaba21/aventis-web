import 'package:flutter/material.dart';
import 'package:asfar/model/geocoding/geocoding_result.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Liste déroulante des suggestions de lieux affichée sous la barre de
/// recherche de la carte (autocomplétion Nominatim).
///
/// Piloté de l'extérieur : reçoit la liste de [GeocodingResult] et un callback
/// de sélection. Style aligné sur le design dark (panneau `bgElev1`, lignes
/// `line`). Vide → ne rend rien.
class MapSearchSuggestions extends StatelessWidget {
  final List<GeocodingResult> suggestions;
  final void Function(GeocodingResult result) onSelected;

  const MapSearchSuggestions({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.line,
        ),
        itemBuilder: (_, index) {
          final s = suggestions[index];
          final parts = s.displayName.split(',');
          final primary = parts.first.trim();
          final secondary = parts.length > 1
              ? parts.sublist(1).join(',').trim()
              : null;

          return InkWell(
            onTap: () => onSelected(s),
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: AppColors.text3,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          primary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        if (secondary != null && secondary.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            secondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
