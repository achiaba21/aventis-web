import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/util/appartement_publication_validator.dart' show ValidationResult;
import 'package:asfar/util/calc/calendar_availability.dart';

/// Validateur du wizard de création de réservation manuelle.
///
/// 4 méthodes statiques, une par étape de validation (cf. business-spec §4.7) :
/// - [validateDates] : pas de chevauchement, ordre cohérent
/// - [validateClient] : nom et téléphone non vides
/// - [validateSource] : si démarcheur partenaire → démarcheurId présent
/// - [validatePaiement] : moyen de paiement renseigné
///
/// Toutes retournent un `ValidationResult` (réutilise la classe existante
/// de `AppartementPublicationValidator` pour cohérence).
class ManualReservationValidator {
  ManualReservationValidator._();

  /// Vérifie la plage de dates demandée.
  ///
  /// Règles :
  /// - [debut] et [fin] non null
  /// - [fin] strictement après [debut]
  /// - aucun chevauchement avec [plages] (`OCCUPE` / `EN_ATTENTE`)
  /// - dates passées **autorisées** (résa rétroactive — cf. spec)
  static ValidationResult validateDates(
    DateTime? debut,
    DateTime? fin,
    List<CalendarPlage> plages,
  ) {
    final errors = <String, String>{};
    if (debut == null) {
      errors['debut'] = "La date d'arrivée est obligatoire";
    }
    if (fin == null) {
      errors['fin'] = 'La date de départ est obligatoire';
    }
    if (debut != null && fin != null) {
      if (!fin.isAfter(debut)) {
        errors['fin'] = 'La date de départ doit être après la date d\'arrivée';
      } else if (!CalendarAvailability.isRangeAvailable(debut, fin, plages)) {
        errors['plage'] =
            'Cette plage chevauche une autre réservation ou un blocage';
      }
    }
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Vérifie les coordonnées du client.
  static ValidationResult validateClient(String? nom, String? telephone) {
    final errors = <String, String>{};
    if (nom == null || nom.trim().isEmpty) {
      errors['nom'] = 'Le nom du client est obligatoire';
    }
    if (telephone == null || telephone.trim().isEmpty) {
      errors['telephone'] = 'Le téléphone est obligatoire';
    }
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Vérifie la source + champs apporteur associés.
  ///
  /// Si [source] est `apporteurExterne` → [apporteurNom] doit être non vide.
  /// Le téléphone reste optionnel (cf. spec backend 2026-05-18).
  static ValidationResult validateSource(
    ReservationManuelleSource? source,
    String? apporteurNom,
  ) {
    final errors = <String, String>{};
    if (source == null) {
      errors['source'] = 'La source est obligatoire';
    } else if (source.requiresApporteurExterne &&
        (apporteurNom == null || apporteurNom.trim().isEmpty)) {
      errors['apporteurNom'] = "Le nom de l'apporteur est obligatoire";
    }
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }

  /// Vérifie le moyen de paiement.
  static ValidationResult validatePaiement(MoyenPaiement? moyen) {
    final errors = <String, String>{};
    if (moyen == null) {
      errors['moyenPaiement'] = 'Le moyen de paiement est obligatoire';
    }
    return errors.isEmpty
        ? const ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
