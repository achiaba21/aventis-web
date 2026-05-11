import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/forms/uploaded_image.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/model/residence/commodite/commodite.dart';
import 'package:asfar/model/residence/offre.dart';
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

  // V9.1 MVP : les règles (Démarcheurs/Caution/Animaux) n'ont pas de champ
  // dédié dans `Appartement` côté Flutter — état local + sérialisation JSON
  // dans `Appartement.regles` au moment du publish. À nettoyer V10 quand
  // le backend expose des champs typés.
  final Map<String, bool> _rules = {
    'demarcheurs': true,
    'caution': true,
    'animaux': false,
  };

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
    final List<XFile> picked = await picker.pickMultiImage(
      limit: 8,
      requestFullMetadata: false,
    );
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

  void _onRuleToggle(String key, bool value) {
    setState(() => _rules[key] = value);
    _scheduleAutoSave();
  }

  void _onRequestGps() {
    context.read<AppartementWizardBloc>().add(FetchInitialLocation());
  }

  bool _canNext(AppartementWizardState state) {
    final draft = state.draft;
    switch (state.currentStep) {
      case 1:
        // Step 1 : typeLocation (rooms) doit être sélectionné.
        return (draft.typeLocation ?? '').isNotEmpty;
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
      // Sérialiser les règles dans Appartement.regles avant publish.
      final rulesJson =
          'demarcheurs=${_rules['demarcheurs']};caution=${_rules['caution']};animaux=${_rules['animaux']}';
      context
          .read<AppartementWizardBloc>()
          .add(UpdateField('description', state.draft.description));
      final updated = state.draft.copyWith(regles: rulesJson);
      // Patch direct (pas via _applyField qui ne gère pas 'regles' string générique)
      // → on dispatch un UpdateField sur un champ dédié si supporté, sinon
      // c'est l'écran qui passe le draft mis à jour au repository.
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
                      rules: _rules,
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
  final Map<String, bool> rules;
  final void Function(String, dynamic) onFieldChange;
  final VoidCallback onRequestGps;
  final VoidCallback onPickPhotos;
  final ValueChanged<int> onRemovePhoto;
  final void Function(String, bool) onRuleToggle;

  const _StepContent({
    required this.state,
    required this.rules,
    required this.onFieldChange,
    required this.onRequestGps,
    required this.onPickPhotos,
    required this.onRemovePhoto,
    required this.onRuleToggle,
  });

  Set<String> _amenitiesFromOffres() {
    final offres = state.draft.offres ?? <Offre>[];
    return offres
        .map((o) => o.commodite?.nom ?? '')
        .where((s) => s.isNotEmpty)
        .toSet();
  }

  void _onAmenityToggle(String amenity) {
    final current = state.draft.offres ?? <Offre>[];
    final bool alreadyActive = current.any(
      (o) => (o.commodite?.nom ?? '') == amenity,
    );
    final List<Offre> updated;
    if (alreadyActive) {
      updated = current
          .where((o) => (o.commodite?.nom ?? '') != amenity)
          .toList();
    } else {
      updated = [
        ...current,
        Offre(commodite: Commodite(nom: amenity)),
      ];
    }
    onFieldChange('offres', updated);
  }

  @override
  Widget build(BuildContext context) {
    switch (state.currentStep) {
      case 1:
        return StepRoomsType(
          selectedRooms: state.draft.typeLocation,
          onSelect: (v) => onFieldChange('typeLocation', v),
        );
      case 2:
        return StepLocationAndCapacity(
          address: state.draft.address,
          title: state.draft.titre,
          description: state.draft.description,
          chambres: state.draft.nbChambres ?? 1,
          douches: state.draft.nbDouches ?? 1,
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
          onToggle: _onAmenityToggle,
        );
      case 5:
        return StepPricing(
          price: state.draft.prix?.toInt(),
          rules: rules,
          onPriceChange: (v) => onFieldChange('prix', v),
          onRuleToggle: onRuleToggle,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

