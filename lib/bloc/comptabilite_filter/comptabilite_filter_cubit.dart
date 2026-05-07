import 'package:flutter_bloc/flutter_bloc.dart';

/// Mode de vue de la comptabilité
enum ComptabiliteViewMode {
  parResidence,
  parAppartement,
}

/// État des filtres de comptabilité
class ComptabiliteFilterState {
  final int? selectedResidenceId;
  final int? selectedAppartementId;
  final DateTime dateDebut;
  final DateTime dateFin;
  final ComptabiliteViewMode viewMode;

  ComptabiliteFilterState({
    this.selectedResidenceId,
    this.selectedAppartementId,
    required this.dateDebut,
    required this.dateFin,
    this.viewMode = ComptabiliteViewMode.parResidence,
  });

  /// État initial avec le mois courant
  factory ComptabiliteFilterState.initial() {
    final now = DateTime.now();
    return ComptabiliteFilterState(
      dateDebut: DateTime(now.year, now.month, 1),
      dateFin: DateTime(now.year, now.month + 1, 0),
    );
  }

  /// Copie avec modifications
  ComptabiliteFilterState copyWith({
    int? selectedResidenceId,
    bool clearSelectedResidence = false,
    int? selectedAppartementId,
    bool clearSelectedAppartement = false,
    DateTime? dateDebut,
    DateTime? dateFin,
    ComptabiliteViewMode? viewMode,
  }) {
    return ComptabiliteFilterState(
      selectedResidenceId: clearSelectedResidence
          ? null
          : (selectedResidenceId ?? this.selectedResidenceId),
      selectedAppartementId: clearSelectedAppartement
          ? null
          : (selectedAppartementId ?? this.selectedAppartementId),
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      viewMode: viewMode ?? this.viewMode,
    );
  }

  /// Label de la période
  String get periodeLabel {
    const mois = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];

    if (dateDebut.month == dateFin.month && dateDebut.year == dateFin.year) {
      return '${mois[dateDebut.month - 1]} ${dateDebut.year}';
    }
    return '${mois[dateDebut.month - 1]} - ${mois[dateFin.month - 1]} ${dateFin.year}';
  }

  /// Est en mode appartement
  bool get isAppartementMode => viewMode == ComptabiliteViewMode.parAppartement;

  /// Est en mode résidence
  bool get isResidenceMode => viewMode == ComptabiliteViewMode.parResidence;
}

/// Cubit pour gérer les filtres de comptabilité
///
/// Gère uniquement les filtres (résidence, appartement, période, mode de vue).
/// Les données (charges, réservations) sont gérées par leurs BLoCs respectifs.
class ComptabiliteFilterCubit extends Cubit<ComptabiliteFilterState> {
  ComptabiliteFilterCubit() : super(ComptabiliteFilterState.initial());

  /// Sélectionner une résidence
  void selectResidence(int? residenceId) {
    emit(state.copyWith(
      selectedResidenceId: residenceId,
      clearSelectedResidence: residenceId == null,
      // Réinitialiser l'appartement quand on change de résidence
      clearSelectedAppartement: true,
    ));
  }

  /// Sélectionner un appartement
  void selectAppartement(int? appartementId) {
    emit(state.copyWith(
      selectedAppartementId: appartementId,
      clearSelectedAppartement: appartementId == null,
    ));
  }

  /// Changer la période
  void selectPeriode(DateTime dateDebut, DateTime dateFin) {
    emit(state.copyWith(
      dateDebut: dateDebut,
      dateFin: dateFin,
    ));
  }

  /// Sélectionner le mois courant
  void selectMoisCourant() {
    final now = DateTime.now();
    emit(state.copyWith(
      dateDebut: DateTime(now.year, now.month, 1),
      dateFin: DateTime(now.year, now.month + 1, 0),
    ));
  }

  /// Sélectionner le mois précédent
  void selectMoisPrecedent() {
    final debut = DateTime(state.dateDebut.year, state.dateDebut.month - 1, 1);
    final fin = DateTime(state.dateDebut.year, state.dateDebut.month, 0);
    emit(state.copyWith(
      dateDebut: debut,
      dateFin: fin,
    ));
  }

  /// Sélectionner le mois suivant
  void selectMoisSuivant() {
    final debut = DateTime(state.dateDebut.year, state.dateDebut.month + 1, 1);
    final fin = DateTime(state.dateDebut.year, state.dateDebut.month + 2, 0);
    emit(state.copyWith(
      dateDebut: debut,
      dateFin: fin,
    ));
  }

  /// Changer le mode de vue
  void changeViewMode(ComptabiliteViewMode mode) {
    emit(state.copyWith(
      viewMode: mode,
      // Réinitialiser l'appartement si on revient en mode résidence
      clearSelectedAppartement: mode == ComptabiliteViewMode.parResidence,
    ));
  }

  /// Basculer entre les modes de vue
  void toggleViewMode() {
    final newMode = state.viewMode == ComptabiliteViewMode.parResidence
        ? ComptabiliteViewMode.parAppartement
        : ComptabiliteViewMode.parResidence;
    changeViewMode(newMode);
  }

  /// Réinitialiser tous les filtres
  void reset() {
    emit(ComptabiliteFilterState.initial());
  }
}
