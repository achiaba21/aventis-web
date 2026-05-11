/// Matrice 4×5 de transformation colorimétrique appliquée aux tuiles OSM
/// pour les passer du thème light (par défaut) au thème **Asfar Premium Dark**.
///
/// Combinaison invert + désaturation : chaque canal RGB est inversé à -0.85,
/// les autres canaux contribuent à -0.10 chacun pour désaturer, offset 255
/// pour compenser. Coût GPU négligeable, aucune dépendance externe.
///
/// Usage avec `flutter_map` :
/// ```dart
/// TileLayer(
///   tileBuilder: (context, tileWidget, tile) {
///     return ColorFiltered(
///       colorFilter: const ColorFilter.matrix(osmDarkMatrix),
///       child: tileWidget,
///     );
///   },
/// )
/// ```
///
/// Partagé entre :
/// - `MapView` (V9.7) — carte interactive plein écran
/// - `MiniMapPreview` (V9.7c) — mini-carte non-interactive sur DetailScreen
const List<double> osmDarkMatrix = <double>[
  -0.85, -0.10, -0.10, 0, 255,
  -0.10, -0.85, -0.10, 0, 255,
  -0.10, -0.10, -0.85, 0, 255,
      0,    0,    0, 1,   0,
];
