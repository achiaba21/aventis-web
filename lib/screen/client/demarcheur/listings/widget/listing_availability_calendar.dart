import 'package:flutter/material.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/screen/client/proprio/appartements/widget/mini_calendar_grid.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';

/// Calendrier de disponibilités lecture seule, intégré inline dans
/// `PartnerListingCard` quand le démarcheur sélectionne un logement.
///
/// Réutilise `MiniCalendarGrid` (cohérence visuelle, 0 duplication).
/// Aucune sélection de date possible — informatif uniquement.
class ListingAvailabilityCalendar extends StatelessWidget {
  final CalendarResponse? data;
  final bool isLoading;
  final DateTime currentMonth;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const ListingAvailabilityCalendar({
    super.key,
    required this.currentMonth,
    this.data,
    this.isLoading = false,
    this.onPrev,
    this.onNext,
  });

  List<int> _daysWithStatut(PlageStatut statut) {
    if (data == null) return const [];
    final days = <int>{};
    final daysInMonth =
        DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
    for (final plage in data!.plages) {
      if (plage.statut != statut) continue;
      for (var d = 1; d <= daysInMonth; d++) {
        if (plage.containsDay(DateTime(currentMonth.year, currentMonth.month, d))) {
          days.add(d);
        }
      }
    }
    return days.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 12),
        child: ShimmerCard(height: 260),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        MiniCalendarGrid(
          currentMonth: currentMonth,
          bookedDays: _daysWithStatut(PlageStatut.occupe),
          pendingDays: _daysWithStatut(PlageStatut.enAttente),
          onPrevMonth: onPrev,
          onNextMonth: onNext,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CalendarLegendDot(color: AppColors.accent),
            const SizedBox(width: 6),
            Text('Réservé', style: AppTextStyles.small),
            const SizedBox(width: 14),
            _CalendarLegendDot(
              color: Colors.transparent,
              border: Border.all(color: AppColors.line, width: 1),
            ),
            const SizedBox(width: 6),
            Text('Libre', style: AppTextStyles.small),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Calendrier informatif — sélection de dates dans l'étape suivante.",
          style: AppTextStyles.small.copyWith(color: AppColors.text3),
        ),
      ],
    );
  }
}

class _CalendarLegendDot extends StatelessWidget {
  final Color color;
  final BoxBorder? border;

  const _CalendarLegendDot({required this.color, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border,
      ),
    );
  }
}
