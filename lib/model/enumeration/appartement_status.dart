// Les noms d'enum sont en UPPER_CASE car ils doivent matcher tels quels les
// valeurs backend via `status.name` (sérialisation/désérialisation).
// ignore_for_file: constant_identifier_names

/// Statut de modération d'une annonce, tel que renvoyé par le backend.
///
/// Machine à états serveur :
/// - `EN_COURS`   : annonce soumise, en attente de validation par la modération.
/// - `EN_LIGNE`   : annonce approuvée et publiée (visible du public).
/// - `HORS_LIGNE` : annonce **retirée par le propriétaire** lui-même (peut la
///   remettre en ligne directement → EN_LIGNE).
/// - `REFUSER`    : annonce **refusée / désactivée par l'admin** (le propriétaire
///   doit la corriger puis la resoumettre → EN_COURS).
enum AppartementStatus {
  EN_COURS,
  EN_LIGNE,
  HORS_LIGNE,
  REFUSER,
}

extension AppartementStatusExtension on AppartementStatus {
  String get value => name;

  /// Parse une valeur backend en `AppartementStatus`.
  ///
  /// Tolérant : insensible à la casse et aux espaces parasites. Retourne `null`
  /// pour une valeur absente ou non reconnue (l'UI retombe alors sur un libellé
  /// neutre plutôt que de présumer un statut).
  static AppartementStatus? fromString(String? value) {
    if (value == null) return null;
    final normalized = value.trim().toUpperCase();
    if (normalized.isEmpty) return null;
    for (final status in AppartementStatus.values) {
      if (status.name == normalized) return status;
    }
    return null;
  }
}
