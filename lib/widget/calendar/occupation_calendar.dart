import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_bloc.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_event.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/occupation/occupation_calendar_mode.dart';
import 'package:asfar/widget/calendar/occupation_day_cell.dart';
import 'package:asfar/widget/calendar/occupation_legend.dart';
import 'package:asfar/widget/loader/circular_progress.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Calendrier d'occupation des appartements
///
/// Affiche un calendrier mensuel avec des bandes de couleur pour visualiser
/// les périodes d'occupation de chaque appartement.
///
/// MODES :
/// - APARTMENT : Affiche l'occupation d'un seul appartement (locataire)
/// - RESIDENCE : Affiche l'occupation de tous les appartements (propriétaire)
///
/// INTERACTIONS :
/// - Locataire : Peut sélectionner des dates non occupées
/// - Propriétaire : Peut cliquer sur une période occupée pour voir les détails
class OccupationCalendar extends StatelessWidget {
  const OccupationCalendar({
    super.key,
    this.mode = OccupationCalendarMode.apartment,
    this.onDateSelected,
    this.onOccupiedPeriodTapped,
    this.enableSelection = false,
  });

  final OccupationCalendarMode mode;
  final Function(DateTime)? onDateSelected;
  final Function(DateTime)? onOccupiedPeriodTapped;
  final bool enableSelection; // True pour mode locataire avec sélection

  static const List<String> _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OccupationCalendarBloc, OccupationCalendarState>(
      builder: (context, state) {
        if (state is OccupationLoading) {
          return const Center(child: CircularProgress());
        }

        if (state is OccupationError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                Gap(Espacement.gapSection),
                TextSeed(
                  state.message,
                  color: AppColors.error,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec navigation
            _buildHeader(context, state),

            Gap(Espacement.gapSection),

            // Jours de la semaine
            _buildWeekDaysRow(),

            Gap(Espacement.gapItem),

            // Grille des jours
            _buildDaysGrid(context, state),

            Gap(Espacement.gapSection),

            // Légende (uniquement en mode résidence avec plusieurs appartements)
            if (state is OccupationLoaded && state.colors.length > 1)
              _buildLegend(state),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, OccupationCalendarState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed:
              () =>
                  context.read<OccupationCalendarBloc>().add(NavigateMonth(-1)),
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        TextSeed(
          _getMonthYearLabel(state.focusedMonth),
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        IconButton(
          onPressed:
              () =>
                  context.read<OccupationCalendarBloc>().add(NavigateMonth(1)),
          icon: Icon(Icons.chevron_right, color: AppColors.textPrimary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildWeekDaysRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children:
          _weekDays
              .map(
                (day) => SizedBox(
                  width: 36,
                  child: TextSeed(
                    day,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildDaysGrid(BuildContext context, OccupationCalendarState state) {
    final days = _getDaysInMonth(state.focusedMonth);
    final rows = <Widget>[];

    for (int i = 0; i < days.length; i += 7) {
      final rowDays = days.sublist(i, (i + 7).clamp(0, days.length));
      // Compléter la ligne si nécessaire
      while (rowDays.length < 7) {
        rowDays.add(null);
      }

      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: Espacement.gapItem),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:
                rowDays
                    .map((date) => _buildDayCell(context, date, state))
                    .toList(),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(
    BuildContext context,
    DateTime? date,
    OccupationCalendarState state,
  ) {
    if (date == null) {
      return const SizedBox(width: 36, height: 36);
    }

    final isToday = _isToday(date);
    final isPast = date.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    );

    // Récupérer les couleurs des occupations pour ce jour
    final periodsForDate = state.getPeriodsForDate(date);
    final occupationColors =
        periodsForDate.map((p) => state.colors[p.appartementId]!).toList();

    // Gérer la sélection (mode locataire uniquement)
    bool isSelected = false;
    if (state is OccupationLoaded && enableSelection) {
      isSelected = state.isSelected(date);
    }

    return OccupationDayCell(
      date: date,
      occupationColors: occupationColors,
      isToday: isToday,
      isSelected: isSelected,
      isPast: isPast,
      allowPastDates: onOccupiedPeriodTapped != null, // Autoriser dates passées si callback propriétaire défini
      onTap: () => _onDayTapped(context, date, state),
    );
  }

  void _onDayTapped(
    BuildContext context,
    DateTime date,
    OccupationCalendarState state,
  ) {
    // Vérifier si le jour est occupé
    final isOccupied = state.isOccupied(date);

    if (isOccupied) {
      // Mode propriétaire : naviguer vers détails de la réservation
      if (onOccupiedPeriodTapped != null) {
        onOccupiedPeriodTapped!(date);
      }
    } else if (enableSelection) {
      // Mode locataire : sélectionner/désélectionner la date
      if (state is OccupationLoaded && state.isSelected(date)) {
        context.read<OccupationCalendarBloc>().add(
          DeselectOccupationDate(date),
        );
      } else {
        context.read<OccupationCalendarBloc>().add(SelectOccupationDate(date));
      }

      if (onDateSelected != null) {
        onDateSelected!(date);
      }
    }
  }

  Widget _buildLegend(OccupationLoaded state) {
    // Construire la map apartmentId → (color, name)
    final Map<int, ({Color color, String name})> apartmentData = {};

    for (final period in state.periods) {
      if (!apartmentData.containsKey(period.appartementId)) {
        apartmentData[period.appartementId] = (
          color: state.colors[period.appartementId]!,
          name: period.appartementName ?? 'Appartement ${period.appartementId}',
        );
      }
    }

    return OccupationLegend(apartmentColors: apartmentData);
  }

  String _getMonthYearLabel(DateTime date) {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<DateTime?> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDay.day;

    // Jour de la semaine du premier jour (1 = lundi, 7 = dimanche)
    int startWeekday = firstDay.weekday;

    final days = <DateTime?>[];

    // Ajouter des cellules vides pour les jours avant le premier du mois
    for (int i = 1; i < startWeekday; i++) {
      days.add(null);
    }

    // Ajouter les jours du mois
    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    return days;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
