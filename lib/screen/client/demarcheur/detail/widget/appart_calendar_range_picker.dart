import 'package:flutter/material.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/screen/client/demarcheur/detail/widget/range_picker_day_cell.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_header.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/util/calc/calendar_availability.dart';

/// Calendrier mensuel cliquable avec sélection d'une plage `[arrivée, départ[`.
///
/// Comportement :
/// - 1er tap → fixe `arrivée`, `départ` à null
/// - 2e tap (jour > arrivée, range libre) → fixe `départ`, range complet
/// - 2e tap (jour ≤ arrivée OU range chevauche une plage occupée) → reset
///   sur ce jour comme nouvelle `arrivée`
/// - 3e tap après range complet → reset nouvelle `arrivée`
///
/// Les jours `OCCUPE` (booked) et `EN_ATTENTE` (pending) sont non-tappables.
/// Les jours passés sont également non-tappables.
class AppartCalendarRangePicker extends StatelessWidget {
  final DateTime currentMonth;
  final List<CalendarPlage> plages;
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime start, DateTime? end) onRangeChanged;

  const AppartCalendarRangePicker({
    super.key,
    required this.currentMonth,
    required this.plages,
    required this.selectedStart,
    required this.selectedEnd,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onRangeChanged,
  });

  static const _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];
  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  int get _daysInMonth =>
      DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

  int get _startOffset =>
      DateTime(currentMonth.year, currentMonth.month, 1).weekday - 1;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  void _onTapDay(DateTime day) {
    final start = selectedStart;
    final end = selectedEnd;

    // Aucune sélection en cours OU range complet → nouveau start.
    if (start == null || end != null) {
      onRangeChanged(day, null);
      return;
    }

    // Une seule borne posée → on tente de poser la 2e.
    if (!day.isAfter(start)) {
      // Reset si on tape sur ou avant le start.
      onRangeChanged(day, null);
      return;
    }
    if (!CalendarAvailability.isRangeAvailable(start, day, plages)) {
      // Range chevauche une plage occupée → reset sur le tap.
      onRangeChanged(day, null);
      return;
    }
    onRangeChanged(start, day);
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final startD = selectedStart == null ? null : _dateOnly(selectedStart!);
    final endD = selectedEnd == null ? null : _dateOnly(selectedEnd!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgElev1,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line, width: 1),
      ),
      child: Column(
        children: [
          MiniCalendarHeader(
            monthTitle:
                '${_monthNames[currentMonth.month - 1]} ${currentMonth.year}',
            onPrev: onPrevMonth,
            onNext: onNextMonth,
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            children: [
              for (final w in _weekdays)
                Center(
                  child: Text(
                    w,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text2,
                    ),
                  ),
                ),
              for (var i = 0; i < _startOffset; i++) const SizedBox.shrink(),
              for (var d = 1; d <= _daysInMonth; d++)
                _buildCell(d, today, startD, endD),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCell(
    int day,
    DateTime today,
    DateTime? startD,
    DateTime? endD,
  ) {
    final dt = DateTime(currentMonth.year, currentMonth.month, day);
    final isPast = dt.isBefore(today);
    final isBooked = plages.any(
      (p) => p.statut == PlageStatut.occupe && p.containsDay(dt),
    );
    final isPending = plages.any(
      (p) => p.statut == PlageStatut.enAttente && p.containsDay(dt),
    );
    final isStart = startD != null && _sameDay(dt, startD);
    final isEnd = endD != null && _sameDay(dt, endD);
    final isInRange = startD != null &&
        endD != null &&
        dt.isAfter(startD) &&
        dt.isBefore(endD);
    final isToday = _sameDay(dt, today);

    return RangePickerDayCell(
      day: day,
      isBooked: isBooked,
      isPending: isPending,
      isStart: isStart,
      isEnd: isEnd,
      isInRange: isInRange,
      isToday: isToday,
      isPast: isPast,
      onTap: () => _onTapDay(dt),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
