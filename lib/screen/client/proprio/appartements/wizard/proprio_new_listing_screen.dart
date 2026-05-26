import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/commodite_cubit/commodite_cubit.dart';
import 'package:asfar/bloc/rule_cubit/rule_cubit.dart';
import 'package:asfar/model/residence/appartement_rule.dart';
import 'package:asfar/util/amenity_catalog.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/enumeration/appartement_type_location.dart';
import 'package:asfar/model/forms/uploaded_image.dart';
import 'package:asfar/model/remise/condition.dart';
import 'package:asfar/model/remise/remise.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/model/residence/offre.dart';
import 'package:asfar/model/residence/rule.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/resume_draft_dialog.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/step_amenities.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/step_location_capacity.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/step_photos.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/step_pricing.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/step_rooms_type.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/wizard_cta_bar.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/wizard_step_indicator.dart';
import 'package:asfar/service/repository/appartement_repository.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/function.dart';
import 'package:asfar/util/navigation.dart';

/// Écran orchestrateur du wizard d'ajout d'appartement — V9.1.
///
/// Pattern : `BlocProvider` local `AppartementWizardBloc` (déjà existant dans
/// `lib/bloc/appartement_wizard_bloc/`) — gère draft Hive + auto-save +
/// validation + state.published.
///
/// Le screen écoute via `BlocListener` :
/// - `state.hasResumableDraft` → affiche `ResumeDraftDialog`
/// - `state.published == true` → déclenche `_publish()` async (appel API)
/// - `state.validationErrors` → SnackBar
///
/// Validation par étape (gating `Continuer`) délégée localement (pas dans
/// le Bloc qui valide la publication globale).
class ProprioNewListingScreen extends StatelessWidget {
  final Appartement? initialEdit;

  const ProprioNewListingScreen({super.key, this.initialEdit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppartementWizardBloc>(
      create: (_) => AppartementWizardBloc()
        ..add(InitWizard(editing: initialEdit)),
      child: _ProprioNewListingView(initialEdit: initialEdit),
    );
  }
}

class _ProprioNewListingView extends StatefulWidget {
  final Appartement? initialEdit;

  const _ProprioNewListingView({this.initialEdit});

  @override
  State<_ProprioNewListingView> createState() => _ProprioNewListingViewState();
}

class _ProprioNewListingViewState extends State<_ProprioNewListingView> {
  Timer? _autoSaveDebouncer;
  bool _publishStarted = false;
  bool _resumeDialogShown = false;

  /// Sélection effective des règles : `ruleId → allowed`. Alimentée par
  /// les toggles du step 5 (cf. `WizardRulesCard`). Les valeurs par défaut
  /// proviennent du référentiel backend `GET /auth/rules` via `RuleCubit`.
  final Map<int, bool> _rulesByRuleId = {};

  /// Construit la liste `appartementRules` au format backend
  /// `[{rule: {id}, isAllowed: bool}]` (cf. brief 2026-05-17 — naming
  /// strict `isAllowed`, sinon le serveur fallback silencieux sur
  /// `defaultAllowed` et le choix proprio est perdu).
  ///
  /// Inclut une entrée par règle du référentiel : valeur explicite si le
  /// proprio a toggleé, sinon `defaultAllowed` du référentiel (le serveur
  /// reçoit toujours toutes les règles avec un état clair).
  List<AppartementRule> _buildAppartementRules() {
    final ruleCubitState = context.read<RuleCubit>().state;
    final refRules = ruleCubitState.rules;
    final result = <AppartementRule>[];
    for (final r in refRules) {
      final id = r.id;
      if (id == null) continue;
      final allowed = _rulesByRuleId.containsKey(id)
          ? _rulesByRuleId[id]!
          : (r.defaultAllowed ?? false);
      result.add(AppartementRule(
        rule: Rule(id: id),
        isAllowed: allowed,
      ));
    }
    return result;
  }

  @override
  void dispose() {
    _autoSaveDebouncer?.cancel();
    super.dispose();
  }

  void _scheduleAutoSave() {
    _autoSaveDebouncer?.cancel();
    _autoSaveDebouncer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<AppartementWizardBloc>().add(TriggerAutoSave());
    });
  }

  Future<void> _onResumeDraftPrompt() async {
    if (_resumeDialogShown) return;
    _resumeDialogShown = true;
    final result = await ResumeDraftDialog.show(context);
    if (!mounted) return;
    final bool resume = result ?? false;
    context.read<AppartementWizardBloc>().add(ResumeDraftDecision(resume));
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    // `pickMultiImage` throw globalement si UNE photo échoue à se charger
    // (cas typique iOS : photo HEIC iPhone, photo iCloud non téléchargée,
    // erreur PlatformException `invalid_image` `NSItemProviderErrorDomain`).
    // On capture l'exception et on signale au proprio sans casser le flow.
    final List<XFile> picked;
    try {
      picked = await picker.pickMultiImage(
        limit: 8,
        requestFullMetadata: false,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      deboger(['_pickPhotos PlatformException', e.code, e.message]);
      _showPhotoErrorSnackBar(
        'Impossible de charger une des photos. Si elles sont sur iCloud, '
        'téléchargez-les d\'abord (Photos → toucher la photo) puis réessayez.',
      );
      return;
    } catch (e) {
      if (!mounted) return;
      deboger(['_pickPhotos error', e.toString()]);
      _showPhotoErrorSnackBar('Échec de la sélection des photos.');
      return;
    }
    if (!mounted || picked.isEmpty) return;
    final bloc = context.read<AppartementWizardBloc>();
    final existing = bloc.state.draft.photos ?? <PhotoAppart>[];
    final added = picked
        .map((x) => PhotoAppart(path: x.path, titre: x.name))
        .toList();
    final combined = [...existing, ...added].take(8).toList();
    bloc.add(UpdateField('photos', combined));
    _scheduleAutoSave();
  }

  void _showPhotoErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _onRemovePhoto(int index) {
    final bloc = context.read<AppartementWizardBloc>();
    final existing = bloc.state.draft.photos ?? <PhotoAppart>[];
    if (index < 0 || index >= existing.length) return;
    final updated = [...existing]..removeAt(index);
    bloc.add(UpdateField('photos', updated));
    _scheduleAutoSave();
  }

  void _onFieldChange(String field, dynamic value) {
    context.read<AppartementWizardBloc>().add(UpdateField(field, value));
    _scheduleAutoSave();
  }

  void _onRuleToggle(int ruleId, bool allowed) {
    setState(() => _rulesByRuleId[ruleId] = allowed);
    _scheduleAutoSave();
  }

  void _onRequestGps() {
    context.read<AppartementWizardBloc>().add(FetchInitialLocation());
  }

  bool _canNext(AppartementWizardState state) {
    final draft = state.draft;
    switch (state.currentStep) {
      case 1:
        // Step 1 : type de logement (enum) doit être sélectionné.
        return draft.typeLocation != null;
      case 2:
        // Step 2 : titre + commune + quartier (address.nom).
        final hasTitre = (draft.titre ?? '').trim().isNotEmpty;
        final hasCommune =
            (draft.address?.commune?.nom ?? '').trim().isNotEmpty;
        final hasArea = (draft.address?.nom ?? '').trim().isNotEmpty;
        return hasTitre && hasCommune && hasArea;
      case 3:
        return (draft.photos?.length ?? 0) >= 3;
      case 4:
        return (draft.offres?.isNotEmpty ?? false);
      case 5:
        return (draft.prix ?? 0) > 0;
      default:
        return false;
    }
  }

  void _onContinue(AppartementWizardState state) {
    if (state.currentStep < state.totalSteps) {
      context.read<AppartementWizardBloc>().add(NextStep());
    } else {
      // Construit la liste `appartementRules` au format backend
      // `[{rule: {id}, allowed}]` (cf. brief 2026-05-16). Le champ `regles`
      // (texte libre) reste vide à la création — le proprio pourra l'éditer
      // via `ListingRulesTab`.
      final updated = state.draft.copyWith(
        appartementRules: _buildAppartementRules(),
      );
      _appartWithRules = updated;
      context.read<AppartementWizardBloc>().add(PublishAppartement());
    }
  }

  Appartement? _appartWithRules;

  Future<void> _publish(AppartementWizardState state) async {
    if (_publishStarted) return;
    _publishStarted = true;

    final messenger = ScaffoldMessenger.of(context);
    final repo = AppartementRepository();
    final draft = _appartWithRules ?? state.draft;

    final images = (draft.photos ?? <PhotoAppart>[])
        .where((p) => (p.path ?? '').isNotEmpty)
        .map((p) => UploadedImage.fromFile(File(p.path!)))
        .toList();

    try {
      await repo.createAppartementWithImages(draft, images);
      if (!mounted) return;
      context.read<AppartementWizardBloc>().add(DiscardDraft());
      context.read<AppartementBloc>().add(RefreshAppartements());
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Annonce publiée'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      back(context);
    } catch (e) {
      deboger('ProprioNewListingScreen._publish: $e');
      if (!mounted) return;
      _publishStarted = false;
      // Reset les flags du bloc pour arrêter le loader et permettre un retry.
      context
          .read<AppartementWizardBloc>()
          .add(PublishAppartementFailed(e.toString()));
      messenger.showSnackBar(
        SnackBar(
          content: Text('Échec de la publication : $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onBack(AppartementWizardState state) {
    if (state.currentStep > 1) {
      context.read<AppartementWizardBloc>().add(PrevStep());
    } else {
      back(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AppartementWizardBloc, AppartementWizardState>(
        listener: (context, state) {
          if (state.hasResumableDraft && !_resumeDialogShown) {
            _onResumeDraftPrompt();
          }
          if (state.published && !_publishStarted) {
            _publish(state);
          }
          if (state.validationErrors.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.validationErrors.values.first),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                WizardStepIndicator(
                  currentStep: state.currentStep,
                  totalSteps: state.totalSteps,
                  onBack: () => _onBack(state),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                    child: _StepContent(
                      state: state,
                      rulesByRuleId: _rulesByRuleId,
                      onFieldChange: _onFieldChange,
                      onRequestGps: _onRequestGps,
                      onPickPhotos: _pickPhotos,
                      onRemovePhoto: _onRemovePhoto,
                      onRuleToggle: _onRuleToggle,
                    ),
                  ),
                ),
                WizardCtaBar(
                  currentStep: state.currentStep,
                  totalSteps: state.totalSteps,
                  canNext: _canNext(state),
                  isPublishing: state.isPublishing,
                  onContinue: () => _onContinue(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final AppartementWizardState state;

  /// Sélection effective des règles : `ruleId → allowed`.
  final Map<int, bool> rulesByRuleId;
  final void Function(String, dynamic) onFieldChange;
  final VoidCallback onRequestGps;
  final VoidCallback onPickPhotos;
  final ValueChanged<int> onRemovePhoto;
  final void Function(int ruleId, bool allowed) onRuleToggle;

  const _StepContent({
    required this.state,
    required this.rulesByRuleId,
    required this.onFieldChange,
    required this.onRequestGps,
    required this.onPickPhotos,
    required this.onRemovePhoto,
    required this.onRuleToggle,
  });

  /// Applique un changement sur la liste des paliers de remise du draft.
  ///
  /// - [addOrUpdate] : palier à ajouter (id null) ou à mettre à jour (id existant)
  /// - [deleteFallback] : palier à retirer (sans id, match par days+montant)
  ///
  /// Reconstruit la `Remise` complète et la pousse via `onFieldChange('remises', ...)`.
  void _applyRemiseChange({
    Condition? addOrUpdate,
    Condition? deleteFallback,
  }) {
    final current =
        List<Condition>.from(state.draft.remises?.conditions ?? const []);
    if (deleteFallback != null) {
      current.removeWhere(
        (c) =>
            c.days == deleteFallback.days &&
            c.montant == deleteFallback.montant,
      );
    }
    if (addOrUpdate != null) {
      final idx = addOrUpdate.id == null
          ? -1
          : current.indexWhere((c) => c.id == addOrUpdate.id);
      if (idx >= 0) {
        current[idx] = addOrUpdate;
      } else {
        current.add(addOrUpdate);
      }
    }
    final updated = Remise(
      id: state.draft.remises?.id,
      conditions: current,
    );
    onFieldChange('remises', updated);
  }

  /// Set des `value` des amenities actuellement sélectionnées. La sélection
  /// est gérée par `value` (clé stable) plutôt que `nom` pour rester aligné
  /// sur le backend (`findByValue`).
  Set<String> _amenitiesFromOffres() {
    final offres = state.draft.offres ?? <Offre>[];
    return offres
        .map((o) => o.commodite?.value ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  /// Toggle une amenity dans la liste des offres du draft.
  ///
  /// - Envoie un `Offre(commodite)` complet avec `nom + value` (+ `id` si
  ///   disponible via `CommoditeCubit`) pour permettre la déduplication
  ///   backend (`findByValue`). Cf. brief mobile « Refonte commodités » §2.
  /// - À la désélection, retire par `value` — préserve les ids existants
  ///   d'autres amenities (pas de régression à l'édition).
  void _onAmenityToggle(BuildContext ctx, AmenityCatalogEntry entry) {
    final current = state.draft.offres ?? <Offre>[];
    final bool alreadyActive = current.any(
      (o) => o.commodite?.value == entry.value,
    );
    final List<Offre> updated;
    if (alreadyActive) {
      updated = current
          .where((o) => o.commodite?.value != entry.value)
          .toList();
    } else {
      // Lookup `id` dans le référentiel chargé (CommoditeCubit). Si absent
      // (cache pas encore chargé), on envoie sans id — le backend retrouvera
      // par `value`.
      final cubitState = ctx.read<CommoditeCubit>().state;
      Commodite? ref;
      for (final c in cubitState.commodites) {
        if (c.value == entry.value) {
          ref = c;
          break;
        }
      }
      updated = [
        ...current,
        Offre(
          commodite: Commodite(
            id: ref?.id,
            nom: ref?.nom ?? entry.label,
            value: entry.value,
          ),
        ),
      ];
    }
    onFieldChange('offres', updated);
  }

  @override
  Widget build(BuildContext context) {
    switch (state.currentStep) {
      case 1:
        return StepRoomsType(
          selectedType: state.draft.typeLocation,
          onSelect: (AppartementTypeLocation v) =>
              onFieldChange('typeLocation', v),
        );
      case 2:
        return StepLocationAndCapacity(
          address: state.draft.address,
          title: state.draft.titre,
          description: state.draft.description,
          lits: state.draft.nbLits ?? 1,
          chambres: state.draft.nbChambres ?? 1,
          douches: state.draft.nbDouches ?? 1,
          typeLocation: state.draft.typeLocation,
          isLoadingGeo: state.isLoadingGeo,
          onFieldChange: onFieldChange,
          onRequestGps: onRequestGps,
        );
      case 3:
        return StepPhotos(
          photos: state.draft.photos ?? const [],
          onPickPhotos: onPickPhotos,
          onRemovePhoto: onRemovePhoto,
        );
      case 4:
        return StepAmenities(
          active: _amenitiesFromOffres(),
          onToggle: (entry) => _onAmenityToggle(context, entry),
        );
      case 5:
        return StepPricing(
          price: state.draft.prix?.toInt(),
          rulesByRuleId: rulesByRuleId,
          remises: state.draft.remises?.conditions ?? const [],
          onPriceChange: (v) => onFieldChange('prix', v),
          onRuleToggle: onRuleToggle,
          onRemiseAdd: (c) => _applyRemiseChange(addOrUpdate: c),
          onRemiseUpdate: (oldC, newC) =>
              _applyRemiseChange(deleteFallback: oldC, addOrUpdate: newC),
          onRemiseDelete: (c) => _applyRemiseChange(deleteFallback: c),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

