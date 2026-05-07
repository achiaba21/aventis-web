import 'package:flutter/material.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Vue jours : affiche le détail des jours du mois avec timeline
///
/// Chaque jour montre les réservations sous forme de barres horizontales
class DaysView extends StatelessWidget {
  const DaysView({
    super.key,
    required this.month,
    required this.reservations,
    required this.appartements,
    required this.colorPalette,
    this.onReservationTapped,
  });

  final DateTime month;
  final List<Reservation> reservations;
  final List<Appartement> appartements;
  final Map<int, Color> colorPalette;
  final Function(Reservation)? onReservationTapped;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    return ListView.separated(
      itemCount: daysInMonth,
      separatorBuilder: (context, index) => SizedBox(height: Espacement.gapItem),
      itemBuilder: (context, index) {
        final day = index + 1;
        final date = DateTime(month.year, month.month, day);
        return _buildDayRow(date);
      },
    );
  }

  /// Construit une ligne de jour avec ses réservations
  Widget _buildDayRow(DateTime date) {
    final reservationsForDay = _getReservationsForDate(date);
    final isToday = _isToday(date);

    return Container(
      padding: EdgeInsets.all(Espacement.paddingInput),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.accent.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(Espacement.radius),
        border: isToday
            ? Border.all(color: AppColors.accent, width: 1)
            : null,
      ),
      child: Row(
        children: [
          // Numéro du jour
          SizedBox(
            width: 40,
            child: Column(
              children: [
                TextSeed(
                  '${date.day}',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                TextSeed(
                  _getWeekDayName(date.weekday),
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          SizedBox(width: Espacement.gapSection),

          // Réservations ou message vide
          Expanded(
            child: reservationsForDay.isEmpty
                ? TextSeed(
                    'Aucune réservation',
                    fontSize: 12,
                    color: AppColors.textMuted,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reservationsForDay
                        .map((r) => _buildReservationBar(r))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  /// Construit une barre de réservation
  Widget _buildReservationBar(Reservation reservation) {
    final color = colorPalette[reservation.appart?.id] ?? AppColors.textMuted;
    final appartName =
        reservation.appart?.titre ?? 'Appartement ${reservation.appart?.id}';

    return GestureDetector(
      onTap: () => onReservationTapped?.call(reservation),
      child: Container(
        margin: EdgeInsets.only(bottom: Espacement.gapItem),
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingInput,
          vertical: Espacement.gapItem,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(Espacement.radius / 2),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            // Pastille de couleur
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: Espacement.gapItem),

            // Nom appartement
            Expanded(
              child: TextSeed(
                appartName,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Durée séjour
            if (reservation.debut != null && reservation.fin != null)
              TextSeed(
                '${_calculateNights(reservation)}n',
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  /// Retourne les réservations pour une date donnée
  List<Reservation> _getReservationsForDate(DateTime date) {
    return reservations.where((r) {
      if (r.statut == ReservationStatus.annulee) return false;
      if (r.debut == null || r.fin == null) return false;

      final start = DateTime(r.debut!.year, r.debut!.month, r.debut!.day);
      final end = DateTime(r.fin!.year, r.fin!.month, r.fin!.day);
      final targetDate = DateTime(date.year, date.month, date.day);

      return (targetDate.isAfter(start) || targetDate.isAtSameMomentAs(start)) &&
          (targetDate.isBefore(end) || targetDate.isAtSameMomentAs(end));
    }).toList();
  }

  /// Vérifie si une date est aujourd'hui
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Retourne le nom du jour de la semaine (L, M, M, J, V, S, D)
  String _getWeekDayName(int weekday) {
    const days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return days[weekday - 1];
  }

  /// Calcule le nombre de nuits
  int _calculateNights(Reservation reservation) {
    if (reservation.debut == null || reservation.fin == null) return 0;
    return reservation.fin!.difference(reservation.debut!).inDays;
  }
}
