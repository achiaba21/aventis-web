import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Grid 7×N du calendrier — `ProprioListingEditScreen` tab Calendrier.
///
/// Reproduit fidèlement le proto `proprietaire.jsx::CalendarView`
/// (lignes 585-625) :
/// - Header chevrons gauche/droite + titre h3 « Novembre 2025 »
/// - 7 colonnes (jours abrégés `L M M J V S D` 11px bold)
/// - Offset au début (cellules vides pour aligner J1 sur le bon jour)
/// - 30 cellules carrées (aspectRatio 1:1) avec couleurs :
///   - Réservé (booked) : fond `accent` + texte `onAccent` w700
///   - En attente (pending) : fond `accentSoft` + texte `accent`
///   - Bloqué (blocked) : fond `bgElev2` + texte `text2` (déblocage au tap)
///   - Aujourd'hui (today, !booked) : border `1.5 accent` + texte `accent`
///   - Disponible : transparent + texte `text` (blocage au tap)
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

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
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

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == currentMonth.year &&
        now.month == currentMonth.month &&
        now.day == day;
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
          _header(),
          const SizedBox(height: 14),
          _grid(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: onPrevMonth,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.text2),
          ),
        ),
        Text(_monthTitle, style: AppTextStyles.h3),
        InkWell(
          onTap: onNextMonth,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.text2),
          ),
        ),
      ],
    );
  }

  Widget _grid() {
    return GridView.count(
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
        for (var d = 1; d <= _daysInMonth; d++) _dayCell(d),
      ],
    );
  }

  Widget _dayCell(int day) {
    final isBooked = bookedDays.contains(day);
    final isPending = pendingDays.contains(day);
    final isBlocked = blockedDays.contains(day);
    final isToday = _isToday(day);

    Color background;
    Color textColor;
    BoxBorder? border;
    FontWeight weight;

    if (isBooked) {
      background = AppColors.accent;
      textColor = AppColors.onAccent;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w700;
    } else if (isPending) {
      background = AppColors.accentSoft;
      textColor = AppColors.accent;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w500;
    } else if (isBlocked) {
      background = AppColors.bgElev2;
      textColor = AppColors.text2;
      border = Border.all(color: AppColors.line, width: 1);
      weight = FontWeight.w500;
    } else if (isToday) {
      background = Colors.transparent;
      textColor = AppColors.accent;
      border = Border.all(color: AppColors.accent, width: 1.5);
      weight = FontWeight.w500;
    } else {
      background = Colors.transparent;
      textColor = AppColors.text;
      border = Border.all(color: Colors.transparent);
      weight = FontWeight.w500;
    }

    final canTap = !isBooked && !isPending && onDayTap != null;
    final tapDate = DateTime(currentMonth.year, currentMonth.month, day);

    return InkWell(
      onTap: canTap ? () => onDayTap!(tapDate) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(fontSize: 12, fontWeight: weight, color: textColor),
        ),
      ),
    );
  }
}
