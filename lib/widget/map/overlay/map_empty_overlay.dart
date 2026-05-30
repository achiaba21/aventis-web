import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Indicateur discret affiché quand aucune résidence n'est disponible sur la
/// carte.
///
/// Pastille flottante compacte ancrée en bas — PAS de voile plein écran : la
/// carte reste lisible et entièrement manipulable (pan/zoom) sous l'indicateur.
/// Utilisé par la carte locataire ET le pane carte démarcheur (R-UNIF map).
/// `title`/`subtitle` sont paramétrables ; bouton de fermeture optionnel.
class MapEmptyOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onDismiss;

  const MapEmptyOverlay({
    super.key,
    this.title = 'Aucune résidence ici',
    this.subtitle = 'Déplacez la carte ou ajustez vos filtres.',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgElev2,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: AppColors.line, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_off_outlined,
                size: 16,
                color: AppColors.text3,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDismiss != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDismiss,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: AppColors.text3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
