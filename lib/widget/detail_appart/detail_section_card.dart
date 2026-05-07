import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget réutilisable pour encapsuler chaque section avec un style cohérent
/// Utilisé dans AppartDetailContent pour structurer les sections
class DetailSectionCard extends StatelessWidget {
  const DetailSectionCard({
    super.key,
    this.title,
    this.icon,
    required this.child,
    this.padding,
    this.showBackground = true,
  });

  /// Titre de la section (optionnel)
  final String? title;

  /// Icône à afficher à côté du titre (optionnel)
  final IconData? icon;

  /// Contenu de la section
  final Widget child;

  /// Padding personnalisé (par défaut: Espacement.paddingBloc)
  final EdgeInsets? padding;

  /// Afficher le fond de la card (par défaut: true)
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre avec icône (si fourni)
        if (title != null) ...[
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.accent,
                  size: 20,
                ),
                Gap(Espacement.gapItem * 2),
              ],
              TextSeed(
                title!,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          Gap(Espacement.gapSection),
        ],
        // Contenu
        child,
      ],
    );

    if (!showBackground) {
      return Padding(
        padding: padding ?? EdgeInsets.all(Espacement.paddingBloc),
        child: content,
      );
    }

    return Container(
      padding: padding ?? EdgeInsets.all(Espacement.paddingBloc),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: content,
    );
  }
}
