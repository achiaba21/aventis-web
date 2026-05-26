import 'package:asfar/model/residence/appart.dart';

/// Événements du wizard d'ajout/édition d'appartement.
abstract class AppartementWizardEvent {}

/// Initialise le wizard. En édition, fournir [editing]. Optionnellement,
/// [startStep] pour ouvrir directement sur une étape donnée (deep-link).
class InitWizard extends AppartementWizardEvent {
  final Appartement? editing;
  final int? startStep;
  InitWizard({this.editing, this.startStep});
}

/// Met à jour un champ du brouillon.
///
/// Champs gérés (clés string) :
/// - `titre: String?`
/// - `description: String?`
/// - `typeLocation: AppartementTypeLocation?` — au changement de type,
///   `nbChambres` est automatiquement recalculé via
///   `TypeLocationChambresPolicy.resolveNbChambres`.
/// - `nbChambres: int?` — utile uniquement pour le cas `cinqPlus`
///   (saisie libre, min 4).
/// - `nbLits: int?`, `nbDouches: int?`, `prix: num?`
/// - `address: Address?`, `addressLatLng: LatLng?`, `addressNom: String?`
/// - `photos: List<PhotoAppart>?`, `offres: List<Offre>?`
/// - `brouillon: bool?`
class UpdateField extends AppartementWizardEvent {
  final String field;
  final dynamic value;
  UpdateField(this.field, this.value);
}

/// Avance d'une étape (avec auto-save).
class NextStep extends AppartementWizardEvent {}

/// Recule d'une étape.
class PrevStep extends AppartementWizardEvent {}

/// Saute directement à l'étape donnée (clamped 1..5).
class GoToStep extends AppartementWizardEvent {
  final int step;
  GoToStep(this.step);
}

/// Déclenche un auto-save explicite (utilisé par le debounce de l'écran).
class TriggerAutoSave extends AppartementWizardEvent {}

/// Tente de publier l'appartement. Si la validation échoue, met à jour
/// `validationErrors` ; sinon active `published = true` pour que l'écran
/// dispatch CreateAppartement / UpdateAppartement vers AppartementBloc.
class PublishAppartement extends AppartementWizardEvent {}

/// Notifie le bloc d'un échec de publication côté écran (catch API).
/// Reset les flags `isPublishing` + `published` pour permettre un retry
/// et arrêter le loader.
class PublishAppartementFailed extends AppartementWizardEvent {
  final String message;
  PublishAppartementFailed(this.message);
}

/// Efface le brouillon courant et réinitialise l'état.
class DiscardDraft extends AppartementWizardEvent {}

/// Réponse de l'utilisateur à la modal "Reprendre votre brouillon ?".
class ResumeDraftDecision extends AppartementWizardEvent {
  final bool resume;
  ResumeDraftDecision(this.resume);
}

/// Demande de récupération de la position GPS courante (avec reverse
/// geocoding) pour préremplir l'étape 1.
class FetchInitialLocation extends AppartementWizardEvent {}
