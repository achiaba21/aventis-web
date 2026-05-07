import 'package:asfar/model/residence/appart.dart';

/// Résultat d'une validation de publication.
///
/// - [isValid] : `true` si tous les critères de publication sont remplis
/// - [errors] : map `champ → message d'erreur` (vide si valide)
class ValidationResult {
  final bool isValid;
  final Map<String, String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });

  /// Construit un résultat valide (aucune erreur).
  const ValidationResult.valid()
      : isValid = true,
        errors = const {};

  /// Construit un résultat invalide à partir d'une map d'erreurs.
  ValidationResult.invalid(this.errors) : isValid = false;
}

/// Valide qu'un [Appartement] est prêt à être publié (pas brouillon).
///
/// Règles métier (cf. business-spec.md §4.2) :
/// - Titre obligatoire (non vide après trim)
/// - Adresse complète (lat + longi non nuls)
/// - Type de location renseigné
/// - Capacité renseignée (chambres ≥ 0, lits ≥ 0, douches ≥ 0)
/// - Prix > 0
/// - **Au moins 3 photos**
///
/// Les méthodes `isStepNComplete` permettent au wizard de valider
/// chaque étape indépendamment et d'activer/désactiver le bouton suivant.
class AppartementPublicationValidator {
  /// Nombre minimum de photos requis pour publier.
  static const int minPhotosToPublish = 3;

  static AppartementPublicationValidator? _instance;

  /// Singleton instance.
  static AppartementPublicationValidator get instance {
    _instance ??= AppartementPublicationValidator._internal();
    return _instance!;
  }

  AppartementPublicationValidator._internal();

  /// Valide l'appartement et retourne la liste des champs manquants/invalides.
  ValidationResult validate(Appartement appart) {
    final errors = <String, String>{};

    if (!_hasTitre(appart)) {
      errors['titre'] = 'Le titre est obligatoire';
    }
    if (!_hasAddress(appart)) {
      errors['address'] = "L'adresse GPS est obligatoire";
    }
    if (!_hasTypeLocation(appart)) {
      errors['typeLocation'] = 'Le type de location est obligatoire';
    }
    if (!_hasCapacity(appart)) {
      errors['capacity'] = 'La capacité (chambres, lits, douches) doit être renseignée';
    }
    if (!_hasPrix(appart)) {
      errors['prix'] = 'Le prix doit être supérieur à 0';
    }
    if (!_hasMinPhotos(appart)) {
      errors['photos'] = '$minPhotosToPublish photos minimum sont requises';
    }

    if (errors.isEmpty) {
      return const ValidationResult.valid();
    }
    return ValidationResult.invalid(errors);
  }

  /// Étape 1 — Adresse : lat + longi requis.
  bool isStep1Complete(Appartement appart) => _hasAddress(appart);

  /// Étape 2 — Description : titre + type de location.
  bool isStep2Complete(Appartement appart) =>
      _hasTitre(appart) && _hasTypeLocation(appart);

  /// Étape 3 — Capacité : chambres + lits + douches.
  bool isStep3Complete(Appartement appart) => _hasCapacity(appart);

  /// Étape 4 — Photos : au moins [minPhotosToPublish].
  bool isStep4Complete(Appartement appart) => _hasMinPhotos(appart);

  /// Étape 5 — Prix : > 0.
  bool isStep5Complete(Appartement appart) => _hasPrix(appart);

  // ============== Prédicats privés ==============

  bool _hasTitre(Appartement a) => (a.titre?.trim().isNotEmpty ?? false);

  bool _hasAddress(Appartement a) =>
      a.address != null && a.address!.lat != null && a.address!.longi != null;

  bool _hasTypeLocation(Appartement a) =>
      a.typeLocation != null && a.typeLocation!.isNotEmpty;

  bool _hasCapacity(Appartement a) =>
      a.nbChambres != null &&
      a.nbLits != null &&
      a.nbDouches != null &&
      a.nbChambres! >= 0 &&
      a.nbLits! >= 0 &&
      a.nbDouches! >= 0;

  bool _hasPrix(Appartement a) => a.prix != null && a.prix! > 0;

  bool _hasMinPhotos(Appartement a) =>
      (a.photos?.length ?? 0) >= minPhotosToPublish;
}
