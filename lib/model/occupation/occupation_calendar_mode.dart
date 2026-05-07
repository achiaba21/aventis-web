/// Mode d'affichage du calendrier d'occupation
///
/// - APARTMENT : Affiche l'occupation d'un seul appartement
/// - RESIDENCE : Affiche l'occupation de tous les appartements d'une résidence
enum OccupationCalendarMode {
  /// Mode appartement unique (locataire + propriétaire)
  apartment('APARTMENT'),

  /// Mode résidence multi-appartements (propriétaire uniquement)
  residence('RESIDENCE');

  const OccupationCalendarMode(this.value);
  final String value;

  /// Crée l'enum depuis une chaîne de caractères
  static OccupationCalendarMode fromString(String value) {
    return OccupationCalendarMode.values.firstWhere(
      (mode) => mode.value == value.toUpperCase(),
      orElse: () => OccupationCalendarMode.apartment,
    );
  }
}
