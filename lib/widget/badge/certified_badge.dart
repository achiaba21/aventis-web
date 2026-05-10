import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Variantes visuelles du [CertifiedBadge].
enum CertifiedBadgeVariant {
  /// Pill translucide rgba(10,10,11,0.7) + texte accent or — overlay sur images.
  translucent,

  /// Carré arrondi (radius 6) fond accent or solide + texte sombre — pour
  /// les FeaturedCards où il sert d'étiquette pleine.
  solid,
}

/// Badge "★ HÔTE CERTIFIÉ" — overlay sur images de listing.
///
/// Deux variantes ([CertifiedBadgeVariant]) : translucide (par défaut) ou
/// solide (utilisé dans les FeaturedCards).
class CertifiedBadge extends StatelessWidget {
  final String label;
  final CertifiedBadgeVariant variant;

  const CertifiedBadge({
    super.key,
    this.label = '★ HÔTE CERTIFIÉ',
    this.variant = CertifiedBadgeVariant.translucent,
  });

  @override
  Widget build(BuildContext context) {
    final isSolid = variant == CertifiedBadgeVariant.solid;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSolid ? 8 : 10,
        vertical: isSolid ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: isSolid ? AppColors.accent : const Color(0xB30A0A0B),
        borderRadius: BorderRadius.circular(isSolid ? 6 : AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSolid ? AppColors.onAccent : AppColors.accent,
          fontSize: isSolid ? 10 : 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
