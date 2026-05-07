import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_event.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_state.dart';
import 'package:asfar/model/occupation/occupation_calendar_mode.dart';
import 'package:asfar/service/color/color_manager.dart';
import 'package:asfar/service/model/occupation/occupation_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour la gestion du calendrier d'occupation
///
/// Responsabilités :
/// - Charger les périodes d'occupation depuis l'API
/// - Gérer les couleurs des appartements via ColorManager
/// - Gérer la navigation entre mois
/// - Gérer la sélection de dates (mode locataire)
class OccupationCalendarBloc
    extends Bloc<OccupationCalendarEvent, OccupationCalendarState> {
  final OccupationService _occupationService;
  final ColorManager _colorManager;

  OccupationCalendarBloc({
    OccupationService? occupationService,
    ColorManager? colorManager,
  })  : _occupationService = occupationService ?? OccupationService(),
        _colorManager = colorManager ?? ColorManager.instance,
        super(OccupationInitial()) {
    on<LoadOccupation>(_onLoadOccupation);
    on<LoadOccupationForResidence>(_onLoadOccupationForResidence);
    on<LoadOccupationFromLocal>(_onLoadOccupationFromLocal);
    on<NavigateMonth>(_onNavigateMonth);
    on<SelectOccupationDate>(_onSelectDate);
    on<DeselectOccupationDate>(_onDeselectDate);
    on<ConfirmSelection>(_onConfirmSelection);
    on<CancelSelection>(_onCancelSelection);
    on<ResetOccupationState>(_onResetState);
  }

  /// Charge l'occupation pour un appartement unique
  Future<void> _onLoadOccupation(
    LoadOccupation event,
    Emitter<OccupationCalendarState> emit,
  ) async {
    emit(OccupationLoading(
      periods: state.periods,
      colors: state.colors,
      focusedMonth: DateTime(event.year, event.month),
      mode: OccupationCalendarMode.apartment,
    ));

    try {
      // Récupérer les périodes d'occupation
      final periods = await _occupationService.getOccupationPeriods(
        appartementId: event.appartementId,
        month: event.month,
        year: event.year,
      );

      // Générer/récupérer la couleur pour cet appartement
      final color = _colorManager.getColorForApartment(event.appartementId);
      final colors = {event.appartementId: color};

      emit(OccupationLoaded(
        periods: periods,
        colors: colors,
        focusedMonth: DateTime(event.year, event.month),
        mode: OccupationCalendarMode.apartment,
        sourceAppartementId: event.appartementId,
      ));

      deboger([
        '[OccupationCalendarBloc] Occupation chargée: ${periods.length} période(s)'
      ]);
    } catch (e) {
      ErrorHandler.logError("LOAD_OCCUPATION", e);
      final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
      emit(OccupationError(
        message: errorMessage,
        periods: state.periods,
        colors: state.colors,
        focusedMonth: DateTime(event.year, event.month),
        mode: OccupationCalendarMode.apartment,
      ));
    }
  }

  /// Charge l'occupation pour une résidence (multi-appartements)
  Future<void> _onLoadOccupationForResidence(
    LoadOccupationForResidence event,
    Emitter<OccupationCalendarState> emit,
  ) async {
    emit(OccupationLoading(
      periods: state.periods,
      colors: state.colors,
      focusedMonth: DateTime(event.year, event.month),
      mode: OccupationCalendarMode.residence,
    ));

    try {
      // Récupérer les périodes pour tous les appartements
      final periods =
          await _occupationService.getOccupationPeriodsForMultipleApartments(
        appartementIds: event.appartementIds,
        month: event.month,
        year: event.year,
      );

      // Générer/récupérer les couleurs pour tous les appartements
      final Map<int, Color> colors = {};
      for (final appartId in event.appartementIds) {
        colors[appartId] = _colorManager.getColorForApartment(appartId);
      }

      emit(OccupationLoaded(
        periods: periods,
        colors: colors,
        focusedMonth: DateTime(event.year, event.month),
        mode: OccupationCalendarMode.residence,
        sourceAppartementIds: event.appartementIds,
      ));

      deboger([
        '[OccupationCalendarBloc] Occupation résidence chargée: ${periods.length} période(s) pour ${event.appartementIds.length} appartement(s)'
      ]);
    } catch (e) {
      ErrorHandler.logError("LOAD_OCCUPATION_RESIDENCE", e);
      final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
      emit(OccupationError(
        message: errorMessage,
        periods: state.periods,
        colors: state.colors,
        focusedMonth: DateTime(event.year, event.month),
        mode: OccupationCalendarMode.residence,
      ));
    }
  }

  /// Charge l'occupation depuis des données locales (sans appel API)
  /// Utilisé pour les propriétaires qui ont déjà les réservations en mémoire
  void _onLoadOccupationFromLocal(
    LoadOccupationFromLocal event,
    Emitter<OccupationCalendarState> emit,
  ) {
    emit(OccupationLoading(
      periods: state.periods,
      colors: state.colors,
      focusedMonth: DateTime(event.year, event.month),
      mode: event.mode,
    ));

    // Récupérer les appartementIds uniques depuis les périodes
    final appartementIds =
        event.periods.map((p) => p.appartementId).toSet().toList();

    // Générer/récupérer les couleurs pour chaque appartement
    final Map<int, Color> colors = {};
    for (final appartId in appartementIds) {
      colors[appartId] = _colorManager.getColorForApartment(appartId);
    }

    emit(OccupationLoaded(
      periods: event.periods,
      colors: colors,
      focusedMonth: DateTime(event.year, event.month),
      mode: event.mode,
      sourceAppartementId: event.mode == OccupationCalendarMode.apartment
          ? appartementIds.firstOrNull
          : null,
      sourceAppartementIds: event.mode == OccupationCalendarMode.residence
          ? appartementIds
          : null,
    ));

    deboger([
      '[OccupationCalendarBloc] Occupation chargée depuis données locales: ${event.periods.length} période(s) pour ${appartementIds.length} appartement(s)'
    ]);
  }

  /// Navigue vers un autre mois et recharge les données correspondantes
  void _onNavigateMonth(
    NavigateMonth event,
    Emitter<OccupationCalendarState> emit,
  ) {
    final currentMonth = state.focusedMonth;
    final newMonth = DateTime(
      currentMonth.year,
      currentMonth.month + event.monthOffset,
    );

    deboger([
      '[OccupationCalendarBloc] Navigation vers ${newMonth.month}/${newMonth.year}'
    ]);

    // Recharger les données selon le mode et le contexte source stocké
    if (state.mode == OccupationCalendarMode.apartment &&
        state.sourceAppartementId != null) {
      add(LoadOccupation(
        appartementId: state.sourceAppartementId!,
        month: newMonth.month,
        year: newMonth.year,
      ));
    } else if (state.mode == OccupationCalendarMode.residence &&
        state.sourceAppartementIds != null &&
        state.sourceAppartementIds!.isNotEmpty) {
      add(LoadOccupationForResidence(
        residenceId: state.sourceAppartementIds!.first,
        appartementIds: state.sourceAppartementIds!,
        month: newMonth.month,
        year: newMonth.year,
      ));
    } else if (state is OccupationLoaded) {
      // Fallback : juste changer le mois si pas de contexte source
      final currentState = state as OccupationLoaded;
      emit(currentState.copyWith(focusedMonth: newMonth));
    }
  }

  /// Sélectionne une date (mode sélection locataire)
  void _onSelectDate(
    SelectOccupationDate event,
    Emitter<OccupationCalendarState> emit,
  ) {
    if (state is! OccupationLoaded) return;

    final currentState = state as OccupationLoaded;
    final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);

    // Vérifier que la date n'est pas occupée
    if (currentState.isOccupied(dateOnly)) {
      deboger(['[OccupationCalendarBloc] Date occupée, sélection bloquée']);
      return;
    }

    // Ajouter la date si pas déjà sélectionnée
    if (!currentState.isSelected(dateOnly)) {
      final newSelection = [...currentState.selectedDates, dateOnly];
      emit(currentState.copyWith(selectedDates: newSelection));
      deboger([
        '[OccupationCalendarBloc] Date sélectionnée: ${event.date.day}/${event.date.month}'
      ]);
    }
  }

  /// Désélectionne une date
  void _onDeselectDate(
    DeselectOccupationDate event,
    Emitter<OccupationCalendarState> emit,
  ) {
    if (state is! OccupationLoaded) return;

    final currentState = state as OccupationLoaded;
    final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);

    final newSelection = currentState.selectedDates
        .where((d) =>
            !(d.year == dateOnly.year &&
                d.month == dateOnly.month &&
                d.day == dateOnly.day))
        .toList();

    emit(currentState.copyWith(selectedDates: newSelection));
    deboger([
      '[OccupationCalendarBloc] Date désélectionnée: ${event.date.day}/${event.date.month}'
    ]);
  }

  /// Confirme la sélection
  void _onConfirmSelection(
    ConfirmSelection event,
    Emitter<OccupationCalendarState> emit,
  ) {
    deboger([
      '[OccupationCalendarBloc] Sélection confirmée: ${event.range.start} - ${event.range.end}'
    ]);
    // L'appelant récupérera la plage confirmée
  }

  /// Annule la sélection
  void _onCancelSelection(
    CancelSelection event,
    Emitter<OccupationCalendarState> emit,
  ) {
    if (state is! OccupationLoaded) return;

    final currentState = state as OccupationLoaded;
    emit(currentState.copyWith(selectedDates: []));
    deboger(['[OccupationCalendarBloc] Sélection annulée']);
  }

  /// Réinitialise l'état
  void _onResetState(
    ResetOccupationState event,
    Emitter<OccupationCalendarState> emit,
  ) {
    deboger(['[OccupationCalendarBloc] Réinitialisation de l\'état']);
    emit(OccupationInitial());
  }
}
