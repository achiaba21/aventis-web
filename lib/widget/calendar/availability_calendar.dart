import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/availability_bloc/availability_bloc.dart';
import 'package:asfar/bloc/availability_bloc/availability_event.dart';
import 'package:asfar/bloc/availability_bloc/availability_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Calendrier de disponibilité pour les propriétaires
/// Permet de voir et bloquer des dates
class AvailabilityCalendar extends StatefulWidget {
  const AvailabilityCalendar({
    super.key,
    required this.appartementId,
    this.isEditable = true,
  });

  final int appartementId;
  final bool isEditable;

  @override
  State<AvailabilityCalendar> createState() => _AvailabilityCalendarState();
}

class _AvailabilityCalendarState extends State<AvailabilityCalendar> {
  late DateTime _focusedMonth;
  final List<String> _weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    // Charger les disponibilités
    context.read<AvailabilityBloc>().add(LoadAvailability(widget.appartementId));
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return months[month - 1];
  }

  List<DateTime?> _getDaysInMonth() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
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
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, day));
    }

    return days;
  }

  void _onDayTapped(DateTime date, AvailabilityState state) {
    if (!widget.isEditable) return;

    // Ne pas permettre de modifier les dates réservées
    if (state.isReserved(date)) return;

    final bloc = context.read<AvailabilityBloc>();

    if (state.isBlocked(date)) {
      // Trouver le bloc correspondant et le débloquer
      final period = state.blockedPeriods.firstWhere(
        (p) => p.contains(date),
        orElse: () => throw Exception('Period not found'),
      );
      bloc.add(UnblockDates(widget.appartementId, period.id));
    } else if (state.isSelected(date)) {
      bloc.add(DeselectDate(date));
    } else {
      bloc.add(SelectDate(date));
    }
  }

  void _confirmBlockSelection(AvailabilityState state) {
    if (state.selectedDates.isEmpty) return;

    final bloc = context.read<AvailabilityBloc>();
    final sortedDates = List<DateTime>.from(state.selectedDates)
      ..sort((a, b) => a.compareTo(b));

    final dateRange = DateTimeRange(
      start: sortedDates.first,
      end: sortedDates.last,
    );

    bloc.add(BlockDates(widget.appartementId, dateRange));
    bloc.add(ClearSelection());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailabilityBloc, AvailabilityState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec navigation
            _buildHeader(),

            Gap(Espacement.gapSection),

            // Jours de la semaine
            _buildWeekDaysRow(),

            Gap(Espacement.gapItem),

            // Grille des jours
            _buildDaysGrid(state),

            Gap(Espacement.gapSection),

            // Légende
            _buildLegend(),

            // Bouton de confirmation si sélection en cours
            if (widget.isEditable && state.selectedDates.isNotEmpty) ...[
              Gap(Espacement.gapSection),
              _buildConfirmButton(state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: _previousMonth,
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        TextSeed(
          '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        IconButton(
          onPressed: _nextMonth,
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
      children: _weekDays
          .map((day) => SizedBox(
                width: 36,
                child: TextSeed(
                  day,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDaysGrid(AvailabilityState state) {
    final days = _getDaysInMonth();
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
            children: rowDays.map((date) => _buildDayCell(date, state)).toList(),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(DateTime? date, AvailabilityState state) {
    if (date == null) {
      return const SizedBox(width: 36, height: 36);
    }

    final status = state.getDateStatus(date);
    final isToday = _isToday(date);
    final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

    Color backgroundColor;
    Color textColor;
    Border? border;

    switch (status) {
      case DateStatus.reserved:
        backgroundColor = AppColors.calendarReserved;
        textColor = AppColors.white;
        break;
      case DateStatus.blocked:
        backgroundColor = AppColors.calendarBlocked;
        textColor = AppColors.white;
        break;
      case DateStatus.selected:
        backgroundColor = AppColors.surfaceVariant;
        textColor = AppColors.textPrimary;
        border = Border.all(color: AppColors.accent, width: 2);
        break;
      case DateStatus.available:
        backgroundColor = isPast ? AppColors.surface : Colors.transparent;
        textColor = isPast ? AppColors.textMuted : AppColors.textPrimary;
        break;
    }

    return GestureDetector(
      onTap: isPast ? null : () => _onDayTapped(date, state),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: border ?? (isToday
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1)
              : null),
        ),
        child: Center(
          child: TextSeed(
            '${date.day}',
            fontSize: 14,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(Colors.transparent, AppColors.textPrimary, 'Disponible'),
        Gap(Espacement.gapSection),
        _buildLegendItem(AppColors.calendarReserved, AppColors.white, 'Réservé'),
        Gap(Espacement.gapSection),
        _buildLegendItem(AppColors.calendarBlocked, AppColors.white, 'Bloqué'),
      ],
    );
  }

  Widget _buildLegendItem(Color bgColor, Color textColor, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: bgColor == Colors.transparent
                ? Border.all(color: AppColors.textSecondary)
                : null,
          ),
        ),
        Gap(4),
        TextSeed(
          label,
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildConfirmButton(AvailabilityState state) {
    final count = state.selectedDates.length;
    return Center(
      child: PlainButton(
        value: 'Bloquer $count date${count > 1 ? 's' : ''}',
        onPress: () => _confirmBlockSelection(state),
      ),
    );
  }
}
