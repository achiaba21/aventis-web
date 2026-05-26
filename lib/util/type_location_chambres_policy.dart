import 'package:asfar/model/enumeration/appartement_type_location.dart';

/// Politique de cohérence entre `AppartementTypeLocation` et `nbChambres`.
///
/// Isolation des règles métier dans un helper statique pur (SRP) :
/// - `resolveNbChambres` est utilisé par le BLoC wizard et l'écran d'édition
///   pour ajuster `nbChambres` au changement de type.
/// - `isCoherent` est utilisé par le validator de publication pour bloquer
///   les paires incohérentes.
///
/// Pour `cinqPlus`, le proprio saisit librement (≥ 4). Pour les autres types,
/// `nbChambres` est figé à la valeur dérivée par l'enum.
class TypeLocationChambresPolicy {
  TypeLocationChambresPolicy._();

  /// Minimum requis pour `cinqPlus` (= 4 chambres + 1 salon → 5 pièces).
  static const int cinqPlusMinChambres = 4;

  /// Calcule la valeur de `nbChambres` à appliquer pour un type donné.
  ///
  /// - Type à dérivation stricte (Studio, 2P, 3P, 4P) → retourne
  ///   `type.derivedNbChambres` quelle que soit `current`.
  /// - `cinqPlus` :
  ///   - si `current` est `null` ou `< 4` → retourne `4` (default min).
  ///   - sinon préserve `current` (saisie proprio déjà valide).
  static int resolveNbChambres(
    AppartementTypeLocation type,
    int? current,
  ) {
    final derived = type.derivedNbChambres;
    if (derived != null) return derived;
    // Cas cinqPlus : préserver la valeur si déjà ≥ 4, sinon forcer au min.
    if (current != null && current >= cinqPlusMinChambres) return current;
    return cinqPlusMinChambres;
  }

  /// Indique si la paire `(type, nbChambres)` respecte la règle métier.
  ///
  /// - Type à dérivation stricte → `nbChambres` doit valoir exactement
  ///   `type.derivedNbChambres`.
  /// - `cinqPlus` → `nbChambres` doit être ≥ 4.
  /// - `nbChambres == null` → toujours incohérent.
  static bool isCoherent(
    AppartementTypeLocation type,
    int? nbChambres,
  ) {
    if (nbChambres == null) return false;
    final derived = type.derivedNbChambres;
    if (derived != null) return nbChambres == derived;
    return nbChambres >= cinqPlusMinChambres;
  }
}
