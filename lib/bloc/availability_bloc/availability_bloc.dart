import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/availability_bloc/availability_event.dart';
import 'package:asfar/bloc/availability_bloc/availability_state.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

/// BLoC pour la gestion des disponibilités des appartements
///
/// Permet au propriétaire de :
/// - Voir les dates réservées et bloquées
/// - Bloquer manuellement des dates
/// - Débloquer des dates précédemment bloquées
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  AvailabilityBloc() : super(AvailabilityInitial()) {
    on<LoadAvailability>(_onLoadAvailability);
    on<RefreshAvailability>(_onRefreshAvailability);
    on<BlockDates>(_onBlockDates);
    on<UnblockDates>(_onUnblockDates);
    on<SelectDate>(_onSelectDate);
    on<DeselectDate>(_onDeselectDate);
    on<ClearSelection>(_onClearSelection);
    on<ResetAvailabilityState>(_onResetState);
  }

  Future<void> _onLoadAvailability(
    LoadAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoading(
      blockedPeriods: state.blockedPeriods,
      reservedPeriods: state.reservedPeriods,
      appartementId: event.appartementId,
    ));

    try {
      // TODO: Appeler l'API pour récupérer les disponibilités
      // final response = await appartementService.getAvailability(event.appartementId);

      // Pour l'instant, simuler des données vides
      await Future.delayed(const Duration(milliseconds: 300));

      emit(AvailabilityLoaded(
        appartementId: event.appartementId,
        blockedPeriods: [],
        reservedPeriods: [],
      ));

      deboger(['[AvailabilityBloc] Disponibilités chargées pour appartement ${event.appartementId}']);
    } catch (e) {
      ErrorHandler.logError("LOAD_AVAILABILITY", e);
      final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
      emit(AvailabilityError(
        message: errorMessage,
        blockedPeriods: state.blockedPeriods,
        reservedPeriods: state.reservedPeriods,
        appartementId: event.appartementId,
      ));
    }
  }

  Future<void> _onRefreshAvailability(
    RefreshAvailability event,
    Emitter<AvailabilityState> emit,
  ) async {
    try {
      // TODO: Appeler l'API pour rafraîchir les disponibilités
      await Future.delayed(const Duration(milliseconds: 300));

      emit(AvailabilityLoaded(
        appartementId: event.appartementId,
        blockedPeriods: state.blockedPeriods,
        reservedPeriods: state.reservedPeriods,
      ));

      deboger(['[AvailabilityBloc] Disponibilités rafraîchies']);
    } catch (e) {
      ErrorHandler.logError("REFRESH_AVAILABILITY", e);
      final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
      emit(AvailabilityError(
        message: errorMessage,
        blockedPeriods: state.blockedPeriods,
        reservedPeriods: state.reservedPeriods,
        appartementId: event.appartementId,
      ));
    }
  }

  Future<void> _onBlockDates(
    BlockDates event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentState = state;
    emit(AvailabilityLoading(
      blockedPeriods: currentState.blockedPeriods,
      reservedPeriods: currentState.reservedPeriods,
      appartementId: event.appartementId,
    ));

    try {
      // TODO: Appeler l'API pour bloquer les dates
      // await appartementService.blockDates(event.appartementId, event.dateRange);

      await Future.delayed(const Duration(milliseconds: 300));

      // Ajouter la nouvelle période bloquée
      final newPeriod = BlockedPeriod(
        id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
        startDate: event.dateRange.start,
        endDate: event.dateRange.end,
      );

      final updatedBlockedPeriods = [...currentState.blockedPeriods, newPeriod];

      emit(AvailabilityOperationSuccess(
        message: 'Dates bloquées avec succès',
        appartementId: event.appartementId,
        blockedPeriods: updatedBlockedPeriods,
        reservedPeriods: currentState.reservedPeriods,
      ));

      // Émettre l'état stable après le succès
      await Future.delayed(const Duration(milliseconds: 300));
      emit(AvailabilityLoaded(
        appartementId: event.appartementId,
        blockedPeriods: updatedBlockedPeriods,
        reservedPeriods: currentState.reservedPeriods,
      ));

      deboger(['[AvailabilityBloc] Dates bloquées: ${event.dateRange.start} - ${event.dateRange.end}']);
    } catch (e) {
      ErrorHandler.logError("BLOCK_DATES", e);
      final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
      emit(AvailabilityError(
        message: errorMessage,
        blockedPeriods: currentState.blockedPeriods,
        reservedPeriods: currentState.reservedPeriods,
        appartementId: event.appartementId,
      ));
    }
  }

  Future<void> _onUnblockDates(
    UnblockDates event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentState = state;
    emit(AvailabilityLoading(
      blockedPeriods: currentState.blockedPeriods,
      reservedPeriods: currentState.reservedPeriods,
      appartementId: event.appartementId,
    ));

    try {
      // TODO: Appeler l'API pour débloquer les dates
      // await appartementService.unblockDates(event.appartementId, event.blockId);

      await Future.delayed(const Duration(milliseconds: 300));

      // Retirer la période bloquée
      final updatedBlockedPeriods = currentState.blockedPeriods
          .where((period) => period.id != event.blockId)
          .toList();

      emit(AvailabilityOperationSuccess(
        message: 'Dates débloquées avec succès',
        appartementId: event.appartementId,
        blockedPeriods: updatedBlockedPeriods,
        reservedPeriods: currentState.reservedPeriods,
      ));

      // Émettre l'état stable après le succès
      await Future.delayed(const Duration(milliseconds: 300));
      emit(AvailabilityLoaded(
        appartementId: event.appartementId,
        blockedPeriods: updatedBlockedPeriods,
        reservedPeriods: currentState.reservedPeriods,
      ));

      deboger(['[AvailabilityBloc] Dates débloquées: blockId=${event.blockId}']);
    } catch (e) {
      ErrorHandler.logError("UNBLOCK_DATES", e);
      final errorMessage = ErrorHandler.extractGenericErrorMessage(e);
      emit(AvailabilityError(
        message: errorMessage,
        blockedPeriods: currentState.blockedPeriods,
        reservedPeriods: currentState.reservedPeriods,
        appartementId: event.appartementId,
      ));
    }
  }

  void _onSelectDate(
    SelectDate event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is! AvailabilityLoaded) return;

    final currentState = state as AvailabilityLoaded;
    final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);

    // Vérifier que la date n'est pas déjà réservée ou bloquée
    if (currentState.isReserved(dateOnly) || currentState.isBlocked(dateOnly)) {
      return;
    }

    // Ajouter la date si elle n'est pas déjà sélectionnée
    if (!currentState.isSelected(dateOnly)) {
      emit(currentState.copyWith(
        selectedDates: [...currentState.selectedDates, dateOnly],
      ));
    }
  }

  void _onDeselectDate(
    DeselectDate event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is! AvailabilityLoaded) return;

    final currentState = state as AvailabilityLoaded;
    final dateOnly = DateTime(event.date.year, event.date.month, event.date.day);

    emit(currentState.copyWith(
      selectedDates: currentState.selectedDates
          .where((d) =>
              d.year != dateOnly.year ||
              d.month != dateOnly.month ||
              d.day != dateOnly.day)
          .toList(),
    ));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<AvailabilityState> emit,
  ) {
    if (state is! AvailabilityLoaded) return;

    final currentState = state as AvailabilityLoaded;
    emit(currentState.copyWith(selectedDates: []));
  }

  void _onResetState(
    ResetAvailabilityState event,
    Emitter<AvailabilityState> emit,
  ) {
    deboger(['[AvailabilityBloc] Réinitialisation de l\'état']);
    emit(AvailabilityInitial());
  }
}
