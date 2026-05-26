import 'package:flutter/material.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_header.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/range_calendar_day_cell.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Calendrier date range picker pour le step 1 du wizard de réservation
/// manuelle.
///
/// Comportement :
/// - Tap sur un jour libre → définit `start`
/// - Tap sur un autre jour libre → définit `end` (si après start) sinon reset à new start
/// - Tap sur la même date que start → reset (déselectionne tout)
/// - Les jours occupés (`OCCUPE` / `EN_ATTENTE`) sont rouges barrés non-tappables
/// - Le bouton end est exclusif (jour de check-out libérable, cf. convention
///   `CalendarPlage.containsDay`)
///
/// Visuellement aligné sur `MiniCalendarGrid` mais avec un atom de cellule
/// dédié (`RangeCalendarDayCell`).
class RangeCalendarPicker extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime? selectedStart;
  final DateTime? selectedEnd;
  final List<CalendarPlage> plages;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final void Function(DateTime tapped) onDayTap;

  const RangeCalendarPicker({
    super.key,
    required this.currentMonth,
    required this.selectedStart,
    required this.selectedEnd,
    required this.plages,
    required this.onDayTap,
    this.onPrevMonth,
    this.onNextMonth,
  });

  static const _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  String get _monthTitle =>
      '${_monthNames[currentMonth.month - 1]} ${currentMonth.year}';

  int get _daysInMonth =>
      DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

  int get _startOffset =>
      DateTime(currentMonth.year, currentMonth.month, 1).weekday - 1;

  int? get _todayDay {
    final now = DateTime.now();
    if (now.year != currentMonth.year || now.month != currentMonth.month) {
      return null;
    }
    return now.day;
  }

  /// Jour aujourd'hui (00:00) — utilisé pour bloquer la sélection passée.
  DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool _isPast(DateTime day) => day.isBefore(_today);

  bool _isUnavailable(DateTime day) {
    // Jours passés non sélectionnables — seules les dates ≥ aujourd'hui sont
    // permises pour saisir une réservation manuelle (pas de saisie rétroactive).
    if (_isPast(day)) return true;
    for (final p in plages) {
      if (p.statut == PlageStatut.disponible) continue;
      if (p.containsDay(day)) return true;
    }
    return false;
  }

  /// Désactive la navigation vers le mois précédent quand on est déjà sur le
  /// mois courant (le passé n'a pas d'intérêt).
  bool get _canGoPrev {
    final today = _today;
    return currentMonth.year > today.year ||
        (currentMonth.year == today.year && currentMonth.month > today.month);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInRange(DateTime day) {
    if (selectedStart == null || selectedEnd == null) return false;
    return day.isAfter(selectedStart!) && day.isBefore(selectedEnd!);
  }

  @override
  Widget build(BuildContext context) {
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
            monthTitle: _monthTitle,
            onPrev: _canGoPrev ? onPrevMonth : null,
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
                RangeCalendarDayCell(
                  day: d,
                  isUnavailable: _isUnavailable(
                    DateTime(currentMonth.year, currentMonth.month, d),
                  ),
                  isStart: selectedStart != null &&
                      _isSameDay(
                        DateTime(currentMonth.year, currentMonth.month, d),
                        selectedStart!,
                      ),
                  isEnd: selectedEnd != null &&
                      _isSameDay(
                        DateTime(currentMonth.year, currentMonth.month, d),
                        selectedEnd!,
                      ),
                  isInRange: _isInRange(
                    DateTime(currentMonth.year, currentMonth.month, d),
                  ),
                  isToday: _todayDay == d,
                  onTap: () => onDayTap(
                    DateTime(currentMonth.year, currentMonth.month, d),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
