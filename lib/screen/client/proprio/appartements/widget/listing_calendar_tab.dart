import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/availability_bloc/availability_bloc.dart';
import 'package:asfar/bloc/availability_bloc/availability_event.dart';
import 'package:asfar/bloc/availability_bloc/availability_state.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/calendar_legend.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_grid.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Tab « Calendrier » du `ProprioListingEditScreen`.
///
/// V8.5 Lot 12 : interactif et branché sur `CalendarPlageBloc` (réservations
/// occupées + en attente, lecture seule) + `AvailabilityBloc` (blocages
/// proprio, édition tap pour bloquer/débloquer). Navigation prev/next mois
/// rejoue `LoadCalendarPlages` avec la nouvelle fenêtre.
class ListingCalendarTab extends StatefulWidget {
  final int? appartementId;

  const ListingCalendarTab({super.key, required this.appartementId});

  @override
  State<ListingCalendarTab> createState() => _ListingCalendarTabState();
}

class _ListingCalendarTabState extends State<ListingCalendarTab> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.appartementId == null) return;
      _loadCurrentMonth();
      context
          .read<AvailabilityBloc>()
          .add(LoadAvailability(widget.appartementId!));
    });
  }

  void _loadCurrentMonth() {
    final id = widget.appartementId;
    if (id == null) return;
    final debut = _currentMonth;
    final fin = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    context.read<CalendarPlageBloc>().add(
          LoadCalendarPlages(
            appartId: id,
            debut: debut,
            fin: fin,
            isDemarcheur: false,
          ),
        );
  }

  void _goToPrevMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
    _loadCurrentMonth();
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
    _loadCurrentMonth();
  }

  void _onDayTap(DateTime day) {
    final id = widget.appartementId;
    if (id == null) return;
    final state = context.read<AvailabilityBloc>().state;
    final blockedPeriods = state.blockedPeriods;
    final existing = blockedPeriods.firstWhere(
      (p) => p.contains(day),
      orElse: () => BlockedPeriod(id: -1, startDate: day, endDate: day),
    );
    if (existing.id != -1) {
      context.read<AvailabilityBloc>().add(UnblockDates(id, existing.id));
      _toast('Date débloquée');
    } else {
      context.read<AvailabilityBloc>().add(
            BlockDates(id, DateTimeRange(start: day, end: day)),
          );
      _toast('Date bloquée');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.appartementId == null) {
      return EmptyState.inline(
        icon: Icons.calendar_today_outlined,
        title: 'Calendrier indisponible',
        body: 'Cette annonce n\'est pas encore enregistrée.',
      );
    }
    return BlocBuilder<CalendarPlageBloc, CalendarPlageState>(
      builder: (context, plagesState) {
        return BlocBuilder<AvailabilityBloc, AvailabilityState>(
          builder: (context, availState) {
            return Column(
              children: [
                MiniCalendarGrid(
                  currentMonth: _currentMonth,
                  bookedDays: _bookedDaysFor(plagesState),
                  pendingDays: _pendingDaysFor(plagesState),
                  blockedDays: _blockedDaysFor(availState),
                  onPrevMonth: _goToPrevMonth,
                  onNextMonth: _goToNextMonth,
                  onDayTap: _onDayTap,
                ),
                const SizedBox(height: 14),
                const CalendarLegend(),
              ],
            );
          },
        );
      },
    );
  }

  List<int> _bookedDaysFor(CalendarPlageState s) {
    if (s is! CalendarPlagesLoaded) return const [];
    return _daysOfMonthFor(
      s.plages.where((p) => p.statut == PlageStatut.occupe),
    );
  }

  List<int> _pendingDaysFor(CalendarPlageState s) {
    if (s is! CalendarPlagesLoaded) return const [];
    return _daysOfMonthFor(
      s.plages.where((p) => p.statut == PlageStatut.enAttente),
    );
  }

  List<int> _daysOfMonthFor(Iterable<CalendarPlage> plages) {
    final days = <int>{};
    for (final p in plages) {
      var cursor = DateTime(p.debut.year, p.debut.month, p.debut.day);
      final end = DateTime(p.fin.year, p.fin.month, p.fin.day);
      while (!cursor.isAfter(end)) {
        if (cursor.year == _currentMonth.year &&
            cursor.month == _currentMonth.month) {
          days.add(cursor.day);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    return days.toList()..sort();
  }

  List<int> _blockedDaysFor(AvailabilityState s) {
    final days = <int>{};
    for (final p in s.blockedPeriods) {
      var cursor = DateTime(p.startDate.year, p.startDate.month, p.startDate.day);
      final end = DateTime(p.endDate.year, p.endDate.month, p.endDate.day);
      while (!cursor.isAfter(end)) {
        if (cursor.year == _currentMonth.year &&
            cursor.month == _currentMonth.month) {
          days.add(cursor.day);
        }
        cursor = cursor.add(const Duration(days: 1));
      }
    }
    return days.toList()..sort();
  }
}
