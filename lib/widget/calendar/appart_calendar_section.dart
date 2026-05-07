import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_event.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/demarcheur/calendrier/helper/day_analysis.dart';
import 'package:asfar/screen/client/demarcheur/calendrier/widget/demarcheurs_en_attente_bottom_sheet.dart';
import 'package:asfar/screen/client/demarcheur/reservations/demarcheur_reservation_form_screen.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

class AppartCalendarSection extends StatefulWidget {
  final Appartement appartement;
  final String userTelephone;

  const AppartCalendarSection({
    super.key,
    required this.appartement,
    required this.userTelephone,
  });

  @override
  State<AppartCalendarSection> createState() => _AppartCalendarSectionState();
}

class _AppartCalendarSectionState extends State<AppartCalendarSection> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _loadCurrentMonth();
  }

  void _loadCurrentMonth() {
    final debut = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final fin = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    context.read<CalendarPlageBloc>().add(LoadCalendarPlages(
          appartId: widget.appartement.id!,
          debut: debut,
          fin: fin,
          isDemarcheur: true,
        ));
  }

  bool get _canGoPrevious {
    final now = DateTime.now();
    return _focusedMonth.year > now.year ||
        (_focusedMonth.year == now.year && _focusedMonth.month > now.month);
  }

  void _previousMonth() {
    if (!_canGoPrevious) return;
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
    _loadCurrentMonth();
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
    _loadCurrentMonth();
  }

  String _monthLabel() {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  void _openForm(DateTime day) {
    pushScreen(
      context,
      DemarcheurReservationFormScreen(
        appartement: widget.appartement,
        dateDebut: day,
      ),
    ).then((_) => _loadCurrentMonth());
  }

  void _openBottomSheet(DateTime day, List<CalendarPlage> plages) {
    final analysis = DayAnalysis(
      plages: plages,
      userTelephone: widget.userTelephone,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DemarcheursEnAttenteBottomSheet(
        plages: plages,
        userTelephone: widget.userTelephone,
        onCreateReservation: analysis.cas == DayCas.c
            ? () {
                Navigator.pop(context);
                _openForm(day);
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MonthNavigator(
          label: _monthLabel(),
          onPrevious: _canGoPrevious ? _previousMonth : null,
          onNext: _nextMonth,
        ),
        const _CalendarLegend(),
        BlocBuilder<CalendarPlageBloc, CalendarPlageState>(
          builder: (context, state) {
            if (state is CalendarPlagesLoading) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is CalendarPlagesError) {
              return SizedBox(
                height: 200,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.error, size: 48),
                        const SizedBox(height: 12),
                        TextSeed(
                          state.message,
                          color: AppColors.textMuted,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadCurrentMonth,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (state is CalendarPlagesLoaded) {
              return _CalendarGrid(
                focusedMonth: _focusedMonth,
                state: state,
                userTelephone: widget.userTelephone,
                onDayTap: _openForm,
                onDayBottomSheet: _openBottomSheet,
              );
            }

            return const SizedBox(height: 200);
          },
        ),
      ],
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  final String label;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
            color: AppColors.accent,
          ),
          TextSeed(
            label,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _LegendItem(color: AppColors.success, label: 'Disponible'),
          _LegendItem(color: AppColors.warning, label: 'Concurrence'),
          _LegendItem(color: AppColors.warning, label: 'Ma demande'),
          _LegendItem(color: AppColors.error, label: 'Occupé'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        TextSeed(label, fontSize: 10, color: AppColors.textMuted),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final CalendarPlagesLoaded state;
  final String userTelephone;
  final void Function(DateTime) onDayTap;
  final void Function(DateTime, List<CalendarPlage>) onDayBottomSheet;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.state,
    required this.userTelephone,
    required this.onDayTap,
    required this.onDayBottomSheet,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startWeekday = (firstDay.weekday - 1) % 7;

    const dayLabels = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayLabels
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: TextSeed(
                          d,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startWeekday + daysInMonth,
            itemBuilder: (context, index) {
              if (index < startWeekday) return const SizedBox.shrink();
              final day = index - startWeekday + 1;
              final date =
                  DateTime(focusedMonth.year, focusedMonth.month, day);
              final plages = state.getPlagesForDay(date);
              final analysis = DayAnalysis(
                plages: plages,
                userTelephone: userTelephone,
              );
              return _DayCell(
                day: day,
                date: date,
                analysis: analysis,
                onTap: () {
                  switch (analysis.cas) {
                    case DayCas.a:
                      onDayTap(date);
                    case DayCas.c:
                    case DayCas.d:
                      onDayBottomSheet(date, plages);
                    case DayCas.b:
                      break;
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final DateTime date;
  final DayAnalysis analysis;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.date,
    required this.analysis,
    required this.onTap,
  });

  bool get _isPast {
    final today = DateTime.now();
    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  Color get _effectiveBgColor {
    if (_isPast) return AppColors.surface;
    return analysis.bgColor;
  }

  bool get _isTappable => !_isPast && analysis.isTappable;

  bool get _isBookable => !_isPast && analysis.isBookable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isTappable ? onTap : null,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _effectiveBgColor,
          borderRadius: BorderRadius.circular(6),
          border: _isBookable
              ? Border.all(color: AppColors.success, width: 0.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextSeed(
              '$day',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _isPast
                  ? AppColors.textSecondary
                  : analysis.cas != DayCas.a
                      ? AppColors.textOnAccent
                      : AppColors.success,
            ),
            if (!_isPast && analysis.hasBadge)
              _BadgeDots(count: analysis.badgeCount),
          ],
        ),
      ),
    );
  }
}

class _BadgeDots extends StatelessWidget {
  final int count;

  const _BadgeDots({required this.count});

  @override
  Widget build(BuildContext context) {
    if (count > 3) {
      return Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          '$count+',
          style: const TextStyle(
            fontSize: 8,
            color: AppColors.textOnAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
          (_) => Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: const BoxDecoration(
              color: AppColors.textOnAccent,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
