import 'package:flutter/material.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/map/base_location_map.dart';

/// Section carte pour afficher la localisation d'un appartement
/// Délègue l'affichage à BaseLocationMap en extrayant les données de l'appartement
///
/// Pour les locataires :
/// - Affiche une localisation approximative (zone de la commune)
/// - onMaskedTap peut déclencher une action (ex: info réservation)
///
/// Pour les propriétaires :
/// - Affiche la localisation exacte avec possibilité d'édition
class AppartMapSection extends StatelessWidget {
  const AppartMapSection({
    super.key,
    required this.appartement,
    this.isOwner = false,
    this.showExactLocation = false,
    this.onEditLocation,
    this.onMaskedTap,
    this.height = 200,
  });

  final Appartement appartement;

  /// true = propriétaire, false = locataire
  final bool isOwner;

  /// true = montrer la localisation exacte (après paiement)
  final bool showExactLocation;

  /// Callback pour éditer la localisation (proprio uniquement)
  final VoidCallback? onEditLocation;

  /// Callback quand l'utilisateur tape sur la zone masquée
  final VoidCallback? onMaskedTap;

  /// Hauteur de la carte
  final double height;

  @override
  Widget build(BuildContext context) {
    final address = appartement.address;

    return BaseLocationMap(
      exactLocation: address?.exactLocation,
      fallbackLocation: address?.hasFallbackLocation == true
          ? address?.fallbackLocation
          : null,
      locationName: address?.locationDisplayName,
      isOwner: isOwner,
      showExactLocation: showExactLocation,
      onEditLocation: onEditLocation,
      onMaskedTap: onMaskedTap,
      height: height,
    );
  }
}
