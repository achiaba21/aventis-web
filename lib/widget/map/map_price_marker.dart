import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Pin de prix sur le [MapPlaceholder].
///
/// Pill 11px / 700, padding 5×10, border line, shadow noire.
/// Mode [active] : fond accent or, texte sombre. Sinon `bgElev2` + texte
/// `text`.
class MapPriceMarker extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const MapPriceMarker({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.line, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? AppColors.onAccent : AppColors.text,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
