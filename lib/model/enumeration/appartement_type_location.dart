/// Type de logement (typologie de pièces) — enum strict de la marketplace Asfar.
///
/// Aligné sur les 5 cards historiques du wizard de création (step 1) :
/// `STUDIO`, `2 pièces`, `3 pièces`, `4 pièces`, `5+ pièces`.
///
/// `nbChambres` est **dérivé** de la valeur dans 4 cas sur 5 (cf. `derivedNbChambres`).
/// Seul `CINQ_PLUS` laisse au proprio la saisie libre du nombre exact (≥ 4).
///
/// Convention métier (cf. business-spec §4.1) :
/// - Studio = pièce unique chambre+salon. Pas de salon séparé.
/// - 2 pièces et + = 1 salon + n chambres.
enum AppartementTypeLocation {
  studio('STUDIO'),
  deuxPieces('DEUX_PIECES'),
  troisPieces('TROIS_PIECES'),
  quatrePieces('QUATRE_PIECES'),
  cinqPlus('CINQ_PLUS');

  const AppartementTypeLocation(this.value);

  /// Valeur sérialisée pour l'échange backend + persistance Hive.
  final String value;

  /// Libellé court affiché à l'utilisateur (proprio + locataire).
  String get label {
    switch (this) {
      case AppartementTypeLocation.studio:
        return 'Studio';
      case AppartementTypeLocation.deuxPieces:
        return '2 pièces';
      case AppartementTypeLocation.troisPieces:
        return '3 pièces';
      case AppartementTypeLocation.quatrePieces:
        return '4 pièces';
      case AppartementTypeLocation.cinqPlus:
        return '5+ pièces';
    }
  }

  /// Sous-titre descriptif — utilisé par les cards du wizard et le picker
  /// d'édition pour expliciter la typologie.
  String get description {
    switch (this) {
      case AppartementTypeLocation.studio:
        return 'Pièce unique séjour + coin nuit';
      case AppartementTypeLocation.deuxPieces:
        return 'Séjour + 1 chambre';
      case AppartementTypeLocation.troisPieces:
        return 'Séjour + 2 chambres';
      case AppartementTypeLocation.quatrePieces:
        return 'Séjour + 3 chambres';
      case AppartementTypeLocation.cinqPlus:
        return 'Grande résidence (4+ chambres)';
    }
  }

  /// Nombre de chambres dérivé du type. `null` pour `cinqPlus` (saisie libre).
  int? get derivedNbChambres {
    switch (this) {
      case AppartementTypeLocation.studio:
      case AppartementTypeLocation.deuxPieces:
        return 1;
      case AppartementTypeLocation.troisPieces:
        return 2;
      case AppartementTypeLocation.quatrePieces:
        return 3;
      case AppartementTypeLocation.cinqPlus:
        return null;
    }
  }

  /// Nombre de lits dérivé du type. Pour `cinqPlus`, retourne la valeur
  /// pré-remplie minimale ; le proprio peut ensuite ajuster librement.
  int get defaultNbLits {
    switch (this) {
      case AppartementTypeLocation.studio:
      case AppartementTypeLocation.deuxPieces:
        return 1;
      case AppartementTypeLocation.troisPieces:
        return 2;
      case AppartementTypeLocation.quatrePieces:
        return 3;
      case AppartementTypeLocation.cinqPlus:
        return 4;
    }
  }

  /// Nombre de salles de bain dérivé du type. Pour `cinqPlus`, pré-remplissage
  /// modifiable.
  int get defaultNbDouches {
    switch (this) {
      case AppartementTypeLocation.studio:
      case AppartementTypeLocation.deuxPieces:
      case AppartementTypeLocation.troisPieces:
        return 1;
      case AppartementTypeLocation.quatrePieces:
      case AppartementTypeLocation.cinqPlus:
        return 2;
    }
  }

  /// `true` uniquement pour `cinqPlus` : le stepper Chambres reste visible
  /// dans le wizard et le proprio doit saisir une valeur ≥ 4.
  bool get requiresFreeChambresInput =>
      this == AppartementTypeLocation.cinqPlus;

  /// Parse strict d'une valeur backend. Retourne `null` si `raw` est `null`/vide,
  /// délègue à [fromLegacy] si la chaîne n'est pas reconnue (forward-compat
  /// avec les anciennes annonces stockant des valeurs libres comme
  /// « Chambre privée », « 3 pièces », etc.).
  static AppartementTypeLocation? fromBackend(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final type in values) {
      if (type.value == raw) return type;
    }
    // Pas une valeur enum stricte → tente le mapping legacy avec nbChambres null
    // (le caller qui dispose de nbChambres préférera appeler fromLegacy direct).
    return fromLegacy(raw, null);
  }

  /// Mapping combiné string legacy + `nbChambres` existant.
  ///
  /// Cf. business-spec §4.6 :
  /// 1. Matching direct sur la chaîne libre (insensible à la casse)
  ///    pour les variantes connues `Studio`, `2 pièces`, etc.
  /// 2. Sinon dérivation depuis `nbChambres` :
  ///    `null|0|1 → DEUX_PIECES`, `2 → TROIS_PIECES`, `3 → QUATRE_PIECES`,
  ///    `≥4 → CINQ_PLUS`.
  ///
  /// Default safe : `deuxPieces` (cas le plus fréquent dans la base).
  static AppartementTypeLocation fromLegacy(String? raw, int? nbChambres) {
    final normalized = raw?.trim().toLowerCase();

    if (normalized != null && normalized.isNotEmpty) {
      if (normalized.contains('studio')) {
        return AppartementTypeLocation.studio;
      }
      if (normalized.startsWith('2') ||
          normalized.contains('2 pièces') ||
          normalized.contains('2p')) {
        return AppartementTypeLocation.deuxPieces;
      }
      if (normalized.startsWith('3') ||
          normalized.contains('3 pièces') ||
          normalized.contains('3p')) {
        return AppartementTypeLocation.troisPieces;
      }
      if (normalized.startsWith('4') ||
          normalized.contains('4 pièces') ||
          normalized.contains('4p')) {
        return AppartementTypeLocation.quatrePieces;
      }
      if (normalized.startsWith('5') ||
          normalized.contains('5+') ||
          normalized.contains('5 pièces')) {
        return AppartementTypeLocation.cinqPlus;
      }
    }

    // Dérivation depuis nbChambres pour les valeurs custom non identifiables
    // (« Chambre privée », « Appartement entier », vide, null…).
    final n = nbChambres ?? 0;
    if (n >= 4) return AppartementTypeLocation.cinqPlus;
    if (n == 3) return AppartementTypeLocation.quatrePieces;
    if (n == 2) return AppartementTypeLocation.troisPieces;
    return AppartementTypeLocation.deuxPieces;
  }
}
