import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/launch_external_maps_helper.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/outlined_custom_button.dart';

/// Bouton "Itinéraire" affiché sur la section Localisation du
/// `LocataireDetailScreen` — V9.7c.
///
/// Visible uniquement quand les coordonnées **réelles** ont été révélées
/// par le backend (post-résa `PAYER/FINALISER`). Tap → ouvre l'app maps
/// native (Apple Maps iOS, Google Maps Android) via `url_launcher`.
///
/// Si aucune app maps n'est installée, [onError] est invoqué (SnackBar
/// discret côté parent).
class ItineraryButton extends StatelessWidget {
  final LatLng coords;
  final VoidCallback? onError;

  const ItineraryButton({
    super.key,
    required this.coords,
    this.onError,
  });

  Future<void> _onTap() async {
    final ok = await LaunchExternalMapsHelper.launchDirections(coords);
    if (!ok) onError?.call();
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedCustomButton(
      text: 'Itinéraire',
      onPressed: _onTap,
      size: ButtonSize.md,
      leadingIcon: Icons.directions_outlined,
      textColor: AppColors.accent,
    );
  }
}
