import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Widget placeholder pour les données sensibles masquées par le serveur
/// Style Call-to-Action avec icône, message et action cliquable
class SensitiveDataPlaceholder extends StatelessWidget {
  /// Message principal à afficher
  final String message;

  /// Label du bouton d'action (optionnel)
  final String? actionLabel;

  /// Icône à afficher
  final IconData icon;

  /// Callback quand l'utilisateur clique sur le placeholder
  final VoidCallback? onTap;

  /// Couleur de l'icône et de l'action (défaut: primaryColor)
  final Color? color;

  /// Afficher en mode compact (moins de padding)
  final bool compact;

  const SensitiveDataPlaceholder({
    super.key,
    this.message = "Informations disponibles après paiement",
    this.actionLabel,
    this.icon = Icons.lock_outline,
    this.onTap,
    this.color,
    this.compact = false,
  });

  /// Factory pour les coordonnées GPS masquées
  factory SensitiveDataPlaceholder.location({
    VoidCallback? onTap,
  }) {
    return SensitiveDataPlaceholder(
      message: "Localisation masquée",
      actionLabel: "Réserver pour voir l'adresse exacte",
      icon: Icons.location_off,
      onTap: onTap,
    );
  }

  /// Factory pour les infos propriétaire masquées
  factory SensitiveDataPlaceholder.proprietaire({
    VoidCallback? onTap,
  }) {
    return SensitiveDataPlaceholder(
      message: "Informations du propriétaire",
      actionLabel: "Disponibles après paiement",
      icon: Icons.person_off,
      onTap: onTap,
    );
  }

  /// Factory pour les infos locataire en attente (vue proprio)
  factory SensitiveDataPlaceholder.locataireAttente() {
    return SensitiveDataPlaceholder(
      message: "En attente de paiement",
      actionLabel: "Coordonnées disponibles après paiement du client",
      icon: Icons.hourglass_empty,
      color: AppColors.warning,
      onTap: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppColors.accent;
    final padding = compact ? Espacement.paddingInput : Espacement.paddingBloc;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(Espacement.radius),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icône dans un container coloré
            Container(
              padding: EdgeInsets.all(compact ? 8 : 12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(Espacement.radius),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: compact ? 20 : 24,
              ),
            ),

            SizedBox(width: Espacement.gapSection),

            // Textes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextSeed(
                    message,
                    fontSize: compact ? 13 : 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                  if (actionLabel != null) ...[
                    SizedBox(height: compact ? 2 : 4),
                    TextSeed(
                      actionLabel!,
                      fontSize: compact ? 12 : 13,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ],
                ],
              ),
            ),

            // Flèche si cliquable
            if (onTap != null) ...[
              SizedBox(width: Espacement.paddingInput),
              Icon(
                Icons.arrow_forward_ios,
                color: accentColor,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
