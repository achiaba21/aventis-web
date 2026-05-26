import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/locolite/address.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/offre.dart';
import 'package:asfar/service/geo/geo_location_service.dart';
import 'package:asfar/service/storage/appartement_draft_storage.dart';
import 'package:asfar/util/appartement_publication_validator.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/type_location_chambres_policy.dart';

/// BLoC du wizard d'ajout/édition d'appartement.
///
/// Responsabilité unique : piloter l'état multi-étapes du wizard, l'auto-save
/// du brouillon en local, et la validation par étape.
///
/// **NE FAIT PAS** d'appel API : la publication finale est déléguée à
/// l'écran qui dispatchera vers `AppartementBloc` quand le state émet
/// `published = true` (couplage faible).
class AppartementWizardBloc extends Bloc<AppartementWizardEvent, AppartementWizardState> {
  final AppartementDraftStorage _draftStorage;
  final GeoLocationService _geoService;
  final AppartementPublicationValidator _validator;

  AppartementWizardBloc({
    AppartementDraftStorage? draftStorage,
    GeoLocationService? geoService,
    AppartementPublicationValidator? validator,
  })  : _draftStorage = draftStorage ?? AppartementDraftStorage.instance,
        _geoService = geoService ?? GeoLocationService.instance,
        _validator = validator ?? AppartementPublicationValidator.instance,
        super(AppartementWizardState.initial()) {
    on<InitWizard>(_onInit);
    on<ResumeDraftDecision>(_onResumeDecision);
    on<FetchInitialLocation>(_onFetchLocation);
    on<UpdateField>(_onUpdateField);
    on<TriggerAutoSave>(_onAutoSave);
    on<NextStep>(_onNextStep);
    on<PrevStep>(_onPrevStep);
    on<GoToStep>(_onGoToStep);
    on<PublishAppartement>(_onPublish);
    on<PublishAppartementFailed>(_onPublishFailed);
    on<DiscardDraft>(_onDiscardDraft);
  }

  void _onPublishFailed(
    PublishAppartementFailed event,
    Emitter<AppartementWizardState> emit,
  ) {
    // Reset les flags pour arrêter le loader et permettre un retry.
    emit(state.copyWith(
      isPublishing: false,
      published: false,
      errorMessage: event.message,
    ));
  }

  Future<void> _onInit(InitWizard event, Emitter<AppartementWizardState> emit) async {
    if (event.editing != null) {
      // Mode édition : pas de proposition de reprendre brouillon
      final startStep = (event.startStep ?? 1).clamp(1, 5);
      emit(AppartementWizardState(
        draft: event.editing!,
        currentStep: startStep,
        isEditing: true,
        canPublish: _validator.validate(event.editing!).isValid,
      ));
      return;
    }

    // Mode création : vérifier l'existence d'un brouillon
    if (_draftStorage.hasDraft()) {
      emit(state.copyWith(hasResumableDraft: true));
      return;
    }

    // Pas de brouillon : démarrer un draft vide et lancer la géoloc
    emit(AppartementWizardState.initial());
    add(FetchInitialLocation());
  }

  Future<void> _onResumeDecision(
    ResumeDraftDecision event,
    Emitter<AppartementWizardState> emit,
  ) async {
    if (event.resume) {
      final loaded = _draftStorage.load() ?? Appartement(brouillon: true);
      emit(state.copyWith(
        draft: loaded,
        hasResumableDraft: false,
        canPublish: _validator.validate(loaded).isValid,
      ));
    } else {
      await _draftStorage.clear();
      emit(AppartementWizardState.initial());
      add(FetchInitialLocation());
    }
  }

  Future<void> _onFetchLocation(
    FetchInitialLocation event,
    Emitter<AppartementWizardState> emit,
  ) async {
    emit(state.copyWith(isLoadingGeo: true));

    final granted = await _geoService.requestPermission();
    if (!granted) {
      deboger('[AppartementWizardBloc] Permission GPS refusée');
      emit(state.copyWith(isLoadingGeo: false));
      return;
    }

    final position = await _geoService.getCurrentLocation();
    if (position == null) {
      deboger('[AppartementWizardBloc] Position GPS indisponible');
      emit(state.copyWith(isLoadingGeo: false));
      return;
    }

    final reverseAddress = await _geoService.reverseGeocode(position);
    final newAddress = Address(
      lat: position.latitude,
      longi: position.longitude,
      nom: reverseAddress,
    );

    final newDraft = state.draft.copyWith(address: newAddress);
    emit(state.copyWith(
      draft: newDraft,
      isLoadingGeo: false,
      canPublish: _validator.validate(newDraft).isValid,
    ));
  }

  void _onUpdateField(UpdateField event, Emitter<AppartementWizardState> emit) {
    final updated = _applyField(state.draft, event.field, event.value);
    emit(state.copyWith(
      draft: updated,
      canPublish: _validator.validate(updated).isValid,
      validationErrors: const {},
    ));
  }

  Future<void> _onAutoSave(
    TriggerAutoSave event,
    Emitter<AppartementWizardState> emit,
  ) async {
    if (state.isEditing) return; // Pas d'auto-save en édition (pas de draft)
    emit(state.copyWith(isSaving: true));
    await _draftStorage.save(state.draft);
    emit(state.copyWith(isSaving: false));
  }

  Future<void> _onNextStep(
    NextStep event,
    Emitter<AppartementWizardState> emit,
  ) async {
    if (state.currentStep >= state.totalSteps) return;
    emit(state.copyWith(currentStep: state.currentStep + 1));
    if (!state.isEditing) {
      await _draftStorage.save(state.draft);
    }
  }

  void _onPrevStep(PrevStep event, Emitter<AppartementWizardState> emit) {
    if (state.currentStep <= 1) return;
    emit(state.copyWith(currentStep: state.currentStep - 1));
  }

  void _onGoToStep(GoToStep event, Emitter<AppartementWizardState> emit) {
    final clamped = event.step.clamp(1, state.totalSteps);
    emit(state.copyWith(currentStep: clamped));
  }

  void _onPublish(PublishAppartement event, Emitter<AppartementWizardState> emit) {
    final result = _validator.validate(state.draft);
    if (!result.isValid) {
      emit(state.copyWith(
        validationErrors: result.errors,
        canPublish: false,
      ));
      return;
    }

    // Marque la publication comme "demandée". L'écran wizard observera
    // ce flag et délèguera à AppartementBloc (couplage faible).
    emit(state.copyWith(
      published: true,
      isPublishing: true,
      validationErrors: const {},
    ));
  }

  Future<void> _onDiscardDraft(
    DiscardDraft event,
    Emitter<AppartementWizardState> emit,
  ) async {
    await _draftStorage.clear();
    emit(AppartementWizardState.initial());
  }

  // ============== Helpers privés ==============

  /// Applique une valeur à un champ du brouillon.
  ///
  /// Centralise la mise à jour pour que l'écran n'ait pas à connaître la
  /// structure interne d'Appartement.
  Appartement _applyField(Appartement draft, String field, dynamic value) {
    switch (field) {
      case 'titre':
        return draft.copyWith(titre: value as String?);
      case 'description':
        return draft.copyWith(description: value as String?);
      case 'typeLocation':
        final newType = value as AppartementTypeLocation?;
        if (newType == null) {
          return draft.copyWith(typeLocation: null);
        }
        // Règle métier : au changement de type, recalculer nbChambres
        // (force la valeur dérivée, ou min 4 pour cinqPlus).
        final resolvedChambres = TypeLocationChambresPolicy.resolveNbChambres(
          newType, draft.nbChambres,
        );
        // Lits + douches : pré-remplis avec les valeurs typiques du type.
        // Pour Studio/2P/3P/4P : valeurs forcées (saisie masquée step 2).
        // Pour 5+ : valeurs initiales modifiables ensuite par le proprio.
        return draft.copyWith(
          typeLocation: newType,
          nbChambres: resolvedChambres,
          nbLits: newType.defaultNbLits,
          nbDouches: newType.defaultNbDouches,
        );
      case 'nbChambres':
        return draft.copyWith(nbChambres: value as int?);
      case 'nbLits':
        return draft.copyWith(nbLits: value as int?);
      case 'nbDouches':
        return draft.copyWith(nbDouches: value as int?);
      case 'prix':
        return draft.copyWith(prix: (value as num?)?.toDouble());
      case 'address':
        return draft.copyWith(address: value as Address?);
      case 'addressLatLng':
        // Helper : value = LatLng → conserve nom/description existants
        final latLng = value as LatLng?;
        if (latLng == null) return draft;
        final current = draft.address ?? Address();
        return draft.copyWith(
          address: Address(
            id: current.id,
            lat: latLng.latitude,
            longi: latLng.longitude,
            nom: current.nom,
            description: current.description,
            commune: current.commune,
            geoLat: current.geoLat,
            geoLongi: current.geoLongi,
          ),
        );
      case 'addressNom':
        final current = draft.address ?? Address();
        return draft.copyWith(
          address: Address(
            id: current.id,
            lat: current.lat,
            longi: current.longi,
            nom: value as String?,
            description: current.description,
            commune: current.commune,
            geoLat: current.geoLat,
            geoLongi: current.geoLongi,
          ),
        );
      case 'remises':
        // value = Remise? (porteur des conditions/paliers de réduction).
        // Cf. step 5 wizard — section Remises long séjour.
        return draft.copyWith(remises: value as Remise?);
      case 'photos':
        return draft.copyWith(photos: value as List<PhotoAppart>?);
      case 'offres':
        return draft.copyWith(offres: value as List<Offre>?);
      case 'brouillon':
        return draft.copyWith(brouillon: value as bool?);
      default:
        deboger('[AppartementWizardBloc] Champ inconnu: $field');
        return draft;
    }
  }
}
