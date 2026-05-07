import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_bloc.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_event.dart';
import 'package:asfar/bloc/appartement_wizard_bloc/appartement_wizard_state.dart';
import 'package:asfar/model/document/photo_appart.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/steps/step_1_address.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/steps/step_2_basics.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/steps/step_3_capacity.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/steps/step_4_media_amenities.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/steps/step_5_pricing_review.dart';
import 'package:asfar/widget/dialog/confirm_dialog.dart';
import 'package:asfar/widget/form/image_uploader.dart';
import 'package:asfar/widget/wizard/wizard_navigation_bar.dart';
import 'package:asfar/widget/wizard/wizard_step_scaffold.dart';

/// Écran orchestrateur du wizard d'ajout/édition d'appartement.
///
/// Provider local pour `AppartementWizardBloc` (état frais à chaque ouverture).
/// Délègue la persistance API à `AppartementBloc` parent (couplage faible).
class AppartementWizardScreen extends StatefulWidget {
  const AppartementWizardScreen({super.key})
      : editing = null,
        startStep = null;

  const AppartementWizardScreen.edit({
    super.key,
    required Appartement this.editing,
    this.startStep,
  });

  final Appartement? editing;
  final int? startStep;

  @override
  State<AppartementWizardScreen> createState() => _AppartementWizardScreenState();
}

class _AppartementWizardScreenState extends State<AppartementWizardScreen> {
  late final PageController _pageController;
  bool _resumeDialogShown = false;
  bool _publishDispatched = false;

  static const _stepTitles = [
    "Adresse",
    "Décrire",
    "Capacité",
    "Photos",
    "Récap",
  ];

  @override
  void initState() {
    super.initState();
    final initialPage = (widget.startStep ?? 1) - 1;
    _pageController = PageController(initialPage: initialPage.clamp(0, 4));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AppartementWizardBloc()
        ..add(InitWizard(editing: widget.editing, startStep: widget.startStep)),
      child: _WizardBody(
        pageController: _pageController,
        stepTitles: _stepTitles,
        resumeDialogShownGetter: () => _resumeDialogShown,
        markResumeDialogShown: () => _resumeDialogShown = true,
        publishDispatchedGetter: () => _publishDispatched,
        markPublishDispatched: () => _publishDispatched = true,
      ),
    );
  }
}

/// Corps du wizard, séparé pour avoir accès au context contenant
/// `AppartementWizardBloc` (provider local).
class _WizardBody extends StatelessWidget {
  const _WizardBody({
    required this.pageController,
    required this.stepTitles,
    required this.resumeDialogShownGetter,
    required this.markResumeDialogShown,
    required this.publishDispatchedGetter,
    required this.markPublishDispatched,
  });

  final PageController pageController;
  final List<String> stepTitles;
  final bool Function() resumeDialogShownGetter;
  final VoidCallback markResumeDialogShown;
  final bool Function() publishDispatchedGetter;
  final VoidCallback markPublishDispatched;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppartementWizardBloc, AppartementWizardState>(
          listenWhen: (prev, next) =>
              prev.currentStep != next.currentStep ||
              prev.hasResumableDraft != next.hasResumableDraft ||
              prev.published != next.published,
          listener: (context, state) async {
            // Sync PageView avec currentStep
            if (pageController.hasClients) {
              final targetPage = state.currentStep - 1;
              if (pageController.page?.round() != targetPage) {
                pageController.animateToPage(
                  targetPage,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }

            // Modal "Reprendre brouillon ?"
            if (state.hasResumableDraft && !resumeDialogShownGetter()) {
              markResumeDialogShown();
              final resume = await ConfirmDialog.show(
                context: context,
                title: "Reprendre votre brouillon ?",
                content:
                    "Un brouillon de bien est sauvegardé. Voulez-vous le reprendre ?",
                confirmText: "Reprendre",
                cancelText: "Repartir de zéro",
              );
              if (context.mounted) {
                context
                    .read<AppartementWizardBloc>()
                    .add(ResumeDraftDecision(resume));
              }
            }

            // Publication demandée → délègue à AppartementBloc
            if (state.published && !publishDispatchedGetter()) {
              if (!context.mounted) return;
              markPublishDispatched();
              _dispatchPublish(context, state);
            }
          },
        ),
        BlocListener<AppartementBloc, AppartementState>(
          listenWhen: (prev, next) =>
              next is AppartementOperationSuccess || next is AppartementError,
          listener: (context, state) async {
            if (state is AppartementOperationSuccess) {
              context.read<AppartementWizardBloc>().add(DiscardDraft());
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            } else if (state is AppartementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<AppartementWizardBloc, AppartementWizardState>(
        builder: (context, state) {
          final stepIndex = (state.currentStep - 1).clamp(0, stepTitles.length - 1);
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              await _handleClose(context, state);
            },
            child: WizardStepScaffold(
              title: stepTitles[stepIndex],
              currentStep: state.currentStep,
              totalSteps: state.totalSteps,
              isSaving: state.isSaving,
              onBack: () => _handleClose(context, state),
              onClose: () => _handleClose(context, state),
              bottomBar: WizardNavigationBar(
                currentStep: state.currentStep,
                totalSteps: state.totalSteps,
                canPublish: state.canPublish,
                isPublishing: state.isPublishing,
                isEditing: state.isEditing,
                onPrev: () =>
                    context.read<AppartementWizardBloc>().add(PrevStep()),
                onNext: () =>
                    context.read<AppartementWizardBloc>().add(NextStep()),
                onPublish: () => context
                    .read<AppartementWizardBloc>()
                    .add(PublishAppartement()),
              ),
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  Step1Address(),
                  Step2Basics(),
                  Step3Capacity(),
                  Step4MediaAmenities(),
                  Step5PricingReview(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleClose(
    BuildContext context,
    AppartementWizardState state,
  ) async {
    // En édition : pop direct (pas de draft à conserver)
    if (state.isEditing) {
      Navigator.of(context).pop();
      return;
    }

    // Création : si rien n'a été saisi, pop direct
    final draft = state.draft;
    final hasContent = (draft.titre?.trim().isNotEmpty ?? false) ||
        draft.address?.lat != null ||
        (draft.photos?.isNotEmpty ?? false) ||
        draft.prix != null;
    if (!hasContent) {
      Navigator.of(context).pop();
      return;
    }

    final keepDraft = await ConfirmDialog.show(
      context: context,
      title: "Quitter le formulaire ?",
      content:
          "Votre progression sera sauvegardée comme brouillon. Vous pourrez la reprendre plus tard.",
      confirmText: "Continuer plus tard",
      cancelText: "Tout abandonner",
    );

    if (!context.mounted) return;

    if (!keepDraft) {
      context.read<AppartementWizardBloc>().add(DiscardDraft());
    }
    Navigator.of(context).pop();
  }

  void _dispatchPublish(BuildContext context, AppartementWizardState state) {
    final draft = state.draft;
    final newImages = _extractNewImages(draft.photos);
    final photosToDelete = state.isEditing
        ? _extractPhotosToDelete(state.draft, _editingOriginal(state))
        : null;

    if (state.isEditing) {
      context.read<AppartementBloc>().add(
            UpdateAppartement(
              draft,
              images: newImages,
              photosToDelete: photosToDelete,
            ),
          );
    } else {
      context.read<AppartementBloc>().add(
            CreateAppartement(draft, images: newImages),
          );
    }
  }

  /// Extrait les photos NOUVELLES (sans uuid, avec un path local) sous forme
  /// de [UploadedImage] prêtes pour le multipart upload.
  List<UploadedImage> _extractNewImages(List<PhotoAppart>? photos) {
    if (photos == null) return const [];
    return photos
        .where((p) => p.uuid == null && p.path != null && p.path!.isNotEmpty)
        .map((p) => UploadedImage(
              id: p.uuid ?? p.path!,
              path: p.path!,
              name: p.titre ?? p.path!.split('/').last,
              file: File(p.path!),
            ))
        .toList();
  }

  /// Extrait les UUIDs des photos qui étaient présentes au début de l'édition
  /// mais qui ne le sont plus dans le draft courant. Retourne null en mode
  /// création.
  List<String>? _extractPhotosToDelete(
    Appartement currentDraft,
    Appartement? original,
  ) {
    if (original == null) return null;
    final originalUuids = (original.photos ?? [])
        .where((p) => p.uuid != null)
        .map((p) => p.uuid!)
        .toSet();
    final currentUuids = (currentDraft.photos ?? [])
        .where((p) => p.uuid != null)
        .map((p) => p.uuid!)
        .toSet();
    return originalUuids.difference(currentUuids).toList();
  }

  /// Heuristique : récupère l'objet original édité depuis le state.
  /// (En l'absence d'un champ dédié, on utilise le draft tel quel — ce qui
  /// signifie que photosToDelete sera toujours vide. Le mode édition réel
  /// doit être géré par l'écran appelant qui passe `editing` au BLoC ;
  /// si on veut tracer les photos supprimées, il faudra étendre le state
  /// avec un champ `originalPhotos`. Pour la V1, photosToDelete = null.)
  Appartement? _editingOriginal(AppartementWizardState state) => null;
}
