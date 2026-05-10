import 'package:flutter/material.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/calendar_legend.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_grid.dart';

/// Tab « Calendrier » du `ProprioListingEditScreen` — view-only.
///
/// Reproduit le proto `proprietaire.jsx::ProprietaireListingEdit::CalendarView`
/// (lignes 585-645) avec mock Novembre 2025 : today=7, offset=5, booked=[9,10,
/// 11,14,15,16,17,22,23,24,25], pending=[28,29].
class ListingCalendarTab extends StatelessWidget {
  const ListingCalendarTab({super.key});

  static const _bookedNov2025 = [9, 10, 11, 14, 15, 16, 17, 22, 23, 24, 25];
  static const _pendingNov2025 = [28, 29];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        MiniCalendarGrid(
          monthTitle: 'Novembre 2025',
          daysInMonth: 30,
          startOffset: 5,
          today: 7,
          bookedDays: _bookedNov2025,
          pendingDays: _pendingNov2025,
        ),
        SizedBox(height: 14),
        CalendarLegend(),
      ],
    );
  }
}
