import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/util/type_location_chambres_policy.dart';

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
/// Règles métier (cf. business-spec.md §4) :
/// - Titre obligatoire (non vide après trim)
/// - Adresse complète (lat + longi non nuls)
/// - `typeLocation` renseigné (enum strict)
/// - `nbChambres` ≥ 1 ET cohérent avec `typeLocation`
///   (Studio/2P → 1, 3P → 2, 4P → 3, 5+ → ≥ 4) — délégué à
///   `TypeLocationChambresPolicy.isCoherent`
/// - `nbLits` ≥ 0 et `nbDouches` ≥ 0
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
      errors['typeLocation'] = 'Le type de logement est obligatoire';
    } else if (!_hasMinChambres(appart)) {
      errors['nbChambres'] = 'Au moins 1 chambre est requise';
    } else if (!_isCapacityCoherentWithType(appart)) {
      errors['nbChambres'] = _incoherenceMessage(appart.typeLocation!);
    }
    if (!_hasLitsAndDouches(appart)) {
      errors['capacity'] =
          'Les lits et salles de bain doivent être renseignés';
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

  /// Étape 3 — Capacité : lits + douches saisis ; chambres soit dérivé du
  /// type, soit ≥ 4 pour `cinqPlus` (cf. règle croisée).
  bool isStep3Complete(Appartement appart) =>
      _hasLitsAndDouches(appart) &&
      _hasMinChambres(appart) &&
      (appart.typeLocation == null ||
          _isCapacityCoherentWithType(appart));

  /// Étape 4 — Photos : au moins [minPhotosToPublish].
  bool isStep4Complete(Appartement appart) => _hasMinPhotos(appart);

  /// Étape 5 — Prix : > 0.
  bool isStep5Complete(Appartement appart) => _hasPrix(appart);

  // ============== Prédicats privés ==============

  bool _hasTitre(Appartement a) => (a.titre?.trim().isNotEmpty ?? false);

  bool _hasAddress(Appartement a) =>
      a.address != null && a.address!.lat != null && a.address!.longi != null;

  bool _hasTypeLocation(Appartement a) => a.typeLocation != null;

  bool _hasMinChambres(Appartement a) => (a.nbChambres ?? 0) >= 1;

  bool _isCapacityCoherentWithType(Appartement a) {
    return TypeLocationChambresPolicy.isCoherent(
      a.typeLocation!,
      a.nbChambres,
    );
  }

  bool _hasLitsAndDouches(Appartement a) =>
      a.nbLits != null &&
      a.nbDouches != null &&
      a.nbLits! >= 0 &&
      a.nbDouches! >= 0;

  bool _hasPrix(Appartement a) => a.prix != null && a.prix! > 0;

  bool _hasMinPhotos(Appartement a) =>
      (a.photos?.length ?? 0) >= minPhotosToPublish;

  String _incoherenceMessage(AppartementTypeLocation type) {
    if (type == AppartementTypeLocation.cinqPlus) {
      return 'Un logement 5+ pièces doit avoir au moins 4 chambres';
    }
    return '${type.label} doit avoir ${type.derivedNbChambres} chambre(s)';
  }
}
