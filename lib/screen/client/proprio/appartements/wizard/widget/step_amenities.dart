import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/amenity_chip_grid.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/amenity_catalog.dart';

/// Étape 4 du wizard — équipements.
///
/// Source des chips = `AmenityCatalog` (référentiel local) aligné sur le
/// référentiel backend `GET /auth/commodites`. Le proprio sélectionne par
/// label, le wizard envoie au serveur un `Offre(Commodite(nom, value, id?))`
/// avec `value` figée pour permettre la déduplication backend (`findByValue`).
///
/// Le `active` set contient les `value` (clés stables) des amenities
/// sélectionnées — plus robuste qu'un set de labels en cas de variation UI.
class StepAmenities extends StatelessWidget {
  /// Set des `value` actifs (ex: `{'wifi', 'ac', 'pool'}`).
  final Set<String> active;

  /// Callback appelé avec la `value` de la chip togglée.
  final void Function(AmenityCatalogEntry entry) onToggle;

  const StepAmenities({
    super.key,
    required this.active,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final essentiels =
        AmenityCatalog.bySection(AmenitySection.essentiels);
    final confort = AmenityCatalog.bySection(AmenitySection.confort);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Équipements', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Sélectionnez tout ce que votre logement propose.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        AmenityChipGrid(
          eyebrow: 'Essentiels',
          entries: essentiels,
          activeValues: active,
          onToggle: onToggle,
        ),
        const SizedBox(height: 18),
        AmenityChipGrid(
          eyebrow: 'Confort',
          entries: confort,
          activeValues: active,
          onToggle: onToggle,
        ),
      ],
    );
  }
}
