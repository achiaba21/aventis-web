import 'package:flutter/material.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_radii.dart';
import 'package:asfar/theme/app_text_styles.dart';

/// Grid 7×N view-only du calendrier — `ProprioListingEditScreen` tab Calendrier.
///
/// Reproduit fidèlement le proto `proprietaire.jsx::CalendarView`
/// (lignes 585-625) :
/// - Header chevrons gauche/droite + titre h3 « Novembre 2025 »
/// - 7 colonnes (jours abrégés `L M M J V S D` 11px bold)
/// - Offset au début (cellules vides pour aligner J1 sur le bon jour)
/// - 30 cellules carrées (aspectRatio 1:1) avec couleurs :
///   - Réservé (booked) : fond `accent` + texte `onAccent` w700
///   - En attente (pending) : fond `accentSoft` + texte `accent`
///   - Aujourd'hui (today, !booked) : border `1.5 accent` + texte `accent`
///   - Disponible : transparent + texte `text`
///
/// View-only : tous les taps (jour ou chevrons) déclenchent un SnackBar.
class MiniCalendarGrid extends StatelessWidget {
  final String monthTitle;
  final int daysInMonth;
  final int startOffset;
  final int today;
  final List<int> bookedDays;
  final List<int> pendingDays;

  const MiniCalendarGrid({
    super.key,
    required this.monthTitle,
    required this.daysInMonth,
    required this.startOffset,
    required this.today,
    required this.bookedDays,
    required this.pendingDays,
  });

  static const _weekdays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  void _navStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation calendrier disponible prochainement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _dayStub(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Édition calendrier disponible prochainement'),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
          _header(context),
          const SizedBox(height: 14),
          _grid(context),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onTap: () => _navStub(context),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.arrow_back_ios_new,
                size: 16, color: AppColors.text2),
          ),
        ),
        Text(monthTitle, style: AppTextStyles.h3),
        InkWell(
          onTap: () => _navStub(context),
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

  Widget _grid(BuildContext context) {
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
        for (var i = 0; i < startOffset; i++) const SizedBox.shrink(),
        for (var d = 1; d <= daysInMonth; d++)
          _dayCell(context, d),
      ],
    );
  }

  Widget _dayCell(BuildContext context, int day) {
    final isBooked = bookedDays.contains(day);
    final isPending = pendingDays.contains(day);
    final isToday = day == today;

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

    return InkWell(
      onTap: () => _dayStub(context),
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
