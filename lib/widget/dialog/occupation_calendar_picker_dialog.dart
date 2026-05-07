import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_bloc.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_event.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/occupation/occupation_calendar_mode.dart';
import 'package:asfar/widget/calendar/occupation_calendar.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Dialog de sélection de dates avec calendrier d'occupation
///
/// Permet au locataire de visualiser les périodes occupées et de sélectionner
/// une plage de dates disponibles.
///
/// USAGE :
/// - Afficher les dates occupées en lecture seule
/// - Permettre la sélection de dates non occupées
/// - Retourner la plage sélectionnée (DateTimeRange?) au clic sur "Confirmer"
class OccupationCalendarPickerDialog extends StatelessWidget {
  const OccupationCalendarPickerDialog({
    super.key,
    required this.appartementId,
    this.initialMonth,
    this.initialYear,
  });

  final int appartementId;
  final int? initialMonth;
  final int? initialYear;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = initialMonth ?? now.month;
    final year = initialYear ?? now.year;

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(Espacement.paddingBloc),
        child: BlocProvider(
          create: (context) => OccupationCalendarBloc()
            ..add(LoadOccupation(
              appartementId: appartementId,
              month: month,
              year: year,
            )),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextSeed(
                'Choisissez vos dates',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              Gap(Espacement.gapItem),
              TextSeed(
                'Les périodes occupées sont indiquées par des bandes de couleur',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),

              Gap(Espacement.gapSection),

              // Calendrier avec sélection activée
              const OccupationCalendar(
                mode: OccupationCalendarMode.apartment,
                enableSelection: true,
              ),

              Gap(Espacement.gapSection),

              // Boutons d'action
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return BlocBuilder<OccupationCalendarBloc, OccupationCalendarState>(
      builder: (context, state) {
        if (state is! OccupationLoaded) {
          // Si pas chargé, afficher juste le bouton Annuler
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: TextSeed(
                'Annuler',
                color: AppColors.textPrimary.withValues(alpha: 0.7),
              ),
            ),
          );
        }

        final hasSelection = state.selectedDates.isNotEmpty;

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Bouton Annuler
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: TextSeed(
                'Annuler',
                color: AppColors.textPrimary.withValues(alpha: 0.7),
              ),
            ),

            Gap(Espacement.gapItem),

            // Bouton Confirmer (désactivé si aucune sélection)
            ElevatedButton(
              onPressed:
                  hasSelection ? () => _confirmSelection(context, state) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    hasSelection ? AppColors.accent : AppColors.textMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: TextSeed(
                'Confirmer',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmSelection(BuildContext context, OccupationLoaded state) {
    if (state.selectedDates.isEmpty) return;

    // Trier les dates et créer la plage
    final sortedDates = List<DateTime>.from(state.selectedDates)
      ..sort((a, b) => a.compareTo(b));

    final range = DateTimeRange(
      start: sortedDates.first,
      end: sortedDates.last,
    );

    // Retourner la plage sélectionnée
    Navigator.pop(context, range);
  }

  /// Affiche le dialog et retourne la plage sélectionnée (ou null si annulé)
  static Future<DateTimeRange?> show({
    required BuildContext context,
    required int appartementId,
    int? initialMonth,
    int? initialYear,
  }) async {
    return await showDialog<DateTimeRange?>(
      context: context,
      builder: (context) => OccupationCalendarPickerDialog(
        appartementId: appartementId,
        initialMonth: initialMonth,
        initialYear: initialYear,
      ),
    );
  }
}
