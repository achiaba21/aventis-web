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

  /// Nombre de mois entre chaque paiement
  int get intervalMois {
    switch (this) {
      case FrequenceCharge.ponctuel:
        return 0;
      case FrequenceCharge.mensuel:
        return 1;
      case FrequenceCharge.bimestriel:
        return 2;
      case FrequenceCharge.trimestriel:
        return 3;
      case FrequenceCharge.semestriel:
        return 6;
      case FrequenceCharge.annuel:
        return 12;
    }
  }

  /// Calcule le montant mensuel équivalent pour une charge donnée
  double montantMensuel(double montant) {
    if (this == FrequenceCharge.ponctuel) return 0;
    return montant / intervalMois;
  }

  /// Parse une valeur (supporte MAJUSCULE et minuscule)
  static FrequenceCharge fromString(String value) {
    final lowerValue = value.toLowerCase();
    return FrequenceCharge.values.firstWhere(
      (e) => e.name == lowerValue,
      orElse: () => FrequenceCharge.mensuel,
    );
  }
}
