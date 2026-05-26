import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/fcfa_formatter.dart';

/// Pin de prix posé sur les tuiles d'une vraie carte FlutterMap.
///
/// Pill compact ~52×26 avec prix compact (`45k`, `1.2M`), fond accent or,
/// texte onAccent w700 mono. Shadow douce pour ressortir sur les tuiles
/// dark. Distinct de [MapPriceMarker] (utilisé pour les pins décoratifs
/// sur `MapPlaceholder`/`MapTeaser`).
class MapPricePin extends StatelessWidget {
  final int price;
  final VoidCallback? onTap;

  const MapPricePin({
    super.key,
    required this.price,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                blurRadius: 4,
                offset: const Offset(0, 2),
                color: Colors.black.withValues(alpha: 0.25),
              ),
            ],
          ),
          child: Text(
            FcfaFormatter.compact(price),
            style: AppTextStyles.mono(const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.onAccent,
            )),
          ),
        ),
      ),
    );
  }
}
