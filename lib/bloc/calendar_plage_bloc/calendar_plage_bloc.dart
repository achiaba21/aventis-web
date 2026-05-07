import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/service/model/calendar/calendar_service.dart';
import 'package:asfar/util/error_handler.dart';
import 'package:asfar/util/function.dart';

class CalendarPlageBloc extends Bloc<CalendarPlageEvent, CalendarPlageState> {
  final CalendarService _service = CalendarService();

  // Paramètres du dernier chargement (pour RefreshCalendarPlages)
  LoadCalendarPlages? _lastLoad;

  CalendarPlageBloc() : super(CalendarPlagesInitial()) {
    on<LoadCalendarPlages>(_onLoadCalendarPlages);
    on<RefreshCalendarPlages>(_onRefreshCalendarPlages);
  }

  Future<void> _onLoadCalendarPlages(
    LoadCalendarPlages event,
    Emitter<CalendarPlageState> emit,
  ) async {
    _lastLoad = event;
    emit(CalendarPlagesLoading());
    try {
      // Par défaut : mois courant
      final debut = event.debut ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
      final fin = event.fin ?? DateTime(DateTime.now().year, DateTime.now().month + 1, 0);

      deboger('[CalendarPlageBloc] load appartId=${event.appartId} isDemarcheur=${event.isDemarcheur}');

      final response = event.isDemarcheur
          ? await _service.getDemarcheurCalendar(event.appartId, debut: debut, fin: fin)
          : await _service.getProprietaireCalendar(event.appartId, debut: debut, fin: fin);

      emit(CalendarPlagesLoaded(
        appartId: response.appartId,
        plages: response.plages,
        debut: debut,
        fin: fin,
      ));
    } catch (e) {
      ErrorHandler.logError('CALENDAR_PLAGE_BLOC_LOAD', e);
      emit(CalendarPlagesError(ErrorHandler.extractGenericErrorMessage(e)));
    }
  }

  Future<void> _onRefreshCalendarPlages(
    RefreshCalendarPlages event,
    Emitter<CalendarPlageState> emit,
  ) async {
    if (_lastLoad == null) return;
    add(_lastLoad!);
  }
}
