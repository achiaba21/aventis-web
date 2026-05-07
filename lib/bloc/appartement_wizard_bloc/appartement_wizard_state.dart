import 'package:asfar/model/residence/appart.dart';

/// État du wizard d'ajout/édition d'appartement.
///
/// Pas de hiérarchie de sous-états : le wizard est piloté par les flags
/// (isLoadingGeo, isSaving, isPublishing, hasResumableDraft, published)
/// et par `currentStep` qui détermine l'écran affiché.
class AppartementWizardState {
  final Appartement draft;
  final int currentStep;
  final int totalSteps;
  final bool isLoadingGeo;
  final bool isSaving;
  final bool isPublishing;
  final Map<String, String> validationErrors;
  final bool canPublish;
  final bool hasResumableDraft;
  final bool published;
  final bool isEditing;
  final String? errorMessage;

  const AppartementWizardState({
    required this.draft,
    this.currentStep = 1,
    this.totalSteps = 5,
    this.isLoadingGeo = false,
    this.isSaving = false,
    this.isPublishing = false,
    this.validationErrors = const {},
    this.canPublish = false,
    this.hasResumableDraft = false,
    this.published = false,
    this.isEditing = false,
    this.errorMessage,
  });

  /// État initial : brouillon vide, étape 1.
  factory AppartementWizardState.initial() {
    return AppartementWizardState(draft: Appartement(brouillon: true));
  }

  AppartementWizardState copyWith({
    Appartement? draft,
    int? currentStep,
    int? totalSteps,
    bool? isLoadingGeo,
    bool? isSaving,
    bool? isPublishing,
    Map<String, String>? validationErrors,
    bool? canPublish,
    bool? hasResumableDraft,
    bool? published,
    bool? isEditing,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AppartementWizardState(
      draft: draft ?? this.draft,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isLoadingGeo: isLoadingGeo ?? this.isLoadingGeo,
      isSaving: isSaving ?? this.isSaving,
      isPublishing: isPublishing ?? this.isPublishing,
      validationErrors: validationErrors ?? this.validationErrors,
      canPublish: canPublish ?? this.canPublish,
      hasResumableDraft: hasResumableDraft ?? this.hasResumableDraft,
      published: published ?? this.published,
      isEditing: isEditing ?? this.isEditing,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
