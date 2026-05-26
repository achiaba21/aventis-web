import 'package:flutter/material.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/range_calendar_picker.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Step 1 du wizard de réservation manuelle — sélection date range.
///
/// Tap sur jour libre → set `start`. Tap sur un autre jour libre après start
/// → set `end`. Tap à nouveau sur start → reset.
class StepDates extends StatefulWidget {
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final List<CalendarPlage> plages;
  final void Function(DateTime? debut, DateTime? fin) onRangeChange;

  const StepDates({
    super.key,
    required this.selectedStart,
    required this.selectedEnd,
    required this.plages,
    required this.onRangeChange,
  });

  @override
  State<StepDates> createState() => _StepDatesState();
}

class _StepDatesState extends State<StepDates> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    final ref = widget.selectedStart ?? DateTime.now();
    _currentMonth = DateTime(ref.year, ref.month, 1);
  }

  void _onPrevMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _onNextMonth() {
    setState(() {
      _currentMonth =
          DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _onDayTap(DateTime day) {
    final start = widget.selectedStart;
    final end = widget.selectedEnd;

    // Cas 1 — Aucune sélection : on définit le start.
    if (start == null) {
      widget.onRangeChange(day, null);
      return;
    }

    // Cas 2 — Sélection complète (start + end) : un 3e tap recommence
    // la sélection au jour tappé (pattern Google Flights / Booking).
    if (end != null) {
      widget.onRangeChange(day, null);
      return;
    }

    // Cas 3 — Seul start défini :
    // - tap après start  → on définit end (exclusif : checkout = jour libérable)
    // - tap avant ou sur start → on redéfinit start (et reset)
    if (day.isAfter(start)) {
      widget.onRangeChange(start, day.add(const Duration(days: 1)));
    } else {
      widget.onRangeChange(day, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.selectedStart;
    final end = widget.selectedEnd;
    // L'end stocké est exclusif (checkout). On affiche la dernière nuit incluse.
    final endVisuel = end?.subtract(const Duration(days: 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quelles dates ?', style: AppTextStyles.h2),
        const SizedBox(height: 6),
        Text(
          'Sélectionnez la date d\'arrivée puis la date de départ. Les jours rouges sont déjà réservés.',
          style: AppTextStyles.body,
        ),
        const SizedBox(height: 18),
        RangeCalendarPicker(
          currentMonth: _currentMonth,
          selectedStart: start,
          selectedEnd: endVisuel,
          plages: widget.plages,
          onPrevMonth: _onPrevMonth,
          onNextMonth: _onNextMonth,
          onDayTap: _onDayTap,
        ),
        const SizedBox(height: 14),
        if (start != null && end != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Arrivée : ${_format(start)} · Départ : ${_format(end)}',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ],
    );
  }

  static String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
