import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';

/// Tile générique pour les bottom-sheet pickers de l'écran filtres.
/// Partagé entre [ListingPartenairePicker] et [ListingZonePicker].
class ListingPickerTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const ListingPickerTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line, width: 1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.text,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_rounded,
                    color: AppColors.accent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
