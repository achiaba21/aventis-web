import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_body.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_header.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';

/// Grid 7×N du calendrier — `ProprioListingEditScreen` tab Calendrier.
///
/// Reproduit fidèlement le proto `proprietaire.jsx::CalendarView`. Header
/// chevrons + titre + 7 colonnes (jours abrégés) + cellules carrées colorées
/// selon état (réservé/en attente/bloqué/aujourd'hui/libre).
///
/// V8.5 Lot 12 : interactif via 3 callbacks (`onPrevMonth`, `onNextMonth`,
/// `onDayTap`). Les jours réservés/en-attente sont non-tappables.
class MiniCalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final List<int> bookedDays;
  final List<int> pendingDays;
  final List<int> blockedDays;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final void Function(DateTime day)? onDayTap;

  const MiniCalendarGrid({
    super.key,
    required this.currentMonth,
    this.bookedDays = const [],
    this.pendingDays = const [],
    this.blockedDays = const [],
    this.onPrevMonth,
    this.onNextMonth,
    this.onDayTap,
  });

  static const _monthNames = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  String get _monthTitle =>
      '${_monthNames[currentMonth.month - 1]} ${currentMonth.year}';

  int get _daysInMonth =>
      DateTime(currentMonth.year, currentMonth.month + 1, 0).day;

  /// Offset Lundi-first : DateTime.weekday = 1 (Lun) … 7 (Dim).
  int get _startOffset {
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    return firstDay.weekday - 1;
  }

  int? get _todayDay {
    final now = DateTime.now();
    if (now.year != currentMonth.year || now.month != currentMonth.month) {
      return null;
    }
    return now.day;
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
            onPrev: onPrevMonth,
            onNext: onNextMonth,
          ),
          const SizedBox(height: 14),
          MiniCalendarBody(
            currentMonth: currentMonth,
            daysInMonth: _daysInMonth,
            startOffset: _startOffset,
            todayDay: _todayDay,
            bookedDays: bookedDays,
            pendingDays: pendingDays,
            blockedDays: blockedDays,
            onDayTap: onDayTap,
          ),
        ],
      ),
    );
  }
}
