/// Fréquence de paiement des charges
enum FrequenceCharge {
  ponctuel,    // Paiement unique
  mensuel,     // Chaque mois
  bimestriel,  // Tous les 2 mois
  trimestriel, // Tous les 3 mois
  semestriel,  // Tous les 6 mois
  annuel,      // Une fois par an
}

extension FrequenceChargeExtension on FrequenceCharge {
  /// Valeur envoyée au serveur (MAJUSCULE)
  String get value => name.toUpperCase();

  String get label {
    switch (this) {
      case FrequenceCharge.ponctuel:
        return 'Ponctuel';
      case FrequenceCharge.mensuel:
        return 'Mensuel';
      case FrequenceCharge.bimestriel:
        return 'Bimestriel';
      case FrequenceCharge.trimestriel:
        return 'Trimestriel';
      case FrequenceCharge.semestriel:
        return 'Semestriel';
      case FrequenceCharge.annuel:
        return 'Annuel';
    }
  }

  /// Indique si la charge est un paiement unique (pas de récurrence).
  bool get isPonctuel => this == FrequenceCharge.ponctuel;

  /// Indique si la charge se répète dans le temps (mensuel, trimestriel, etc.).
  bool get isRecurrente => !isPonctuel;

  /// Parse une valeur (supporte MAJUSCULE et minuscule)
  static FrequenceCharge fromString(String value) {
    final lowerValue = value.toLowerCase();
    return FrequenceCharge.values.firstWhere(
      (e) => e.name == lowerValue,
      orElse: () => FrequenceCharge.mensuel,
    );
  }
}
