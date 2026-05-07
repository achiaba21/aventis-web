import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_bloc.dart';
import 'package:asfar/bloc/occupation_calendar_bloc/occupation_calendar_event.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/occupation/occupation_calendar_mode.dart';
import 'package:asfar/model/occupation/occupation_period.dart';
import 'package:asfar/widget/calendar/occupation_calendar.dart';
import 'package:asfar/widget/text/text_seed.dart';
import 'package:asfar/theme/app_colors.dart';

/// Dialog de visualisation du calendrier d'occupation pour propriétaires
///
/// Affiche le calendrier d'occupation d'un appartement ou d'une résidence entière.
/// Permet au propriétaire de visualiser les périodes occupées et de cliquer
/// sur une période pour voir les détails de la réservation.
///
/// MODES :
/// - APARTMENT : Affiche l'occupation d'un seul appartement
/// - RESIDENCE : Affiche l'occupation de tous les appartements de la résidence
class OccupationCalendarDialog extends StatelessWidget {
  const OccupationCalendarDialog({
    super.key,
    required this.mode,
    this.appartementId,
    this.residenceId,
    this.appartementIds = const [],
    this.localPeriods,
    this.onOccupiedPeriodTapped,
    this.initialMonth,
    this.initialYear,
  });

  final OccupationCalendarMode mode;
  final int? appartementId; // Requis si mode APARTMENT
  final int? residenceId; // Requis si mode RESIDENCE
  final List<int> appartementIds; // Requis si mode RESIDENCE
  final List<OccupationPeriod>? localPeriods; // Optionnel : utiliser données locales (propriétaires)
  final Function(DateTime)? onOccupiedPeriodTapped; // Callback quand clic sur période occupée
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
          create: (context) {
            final bloc = OccupationCalendarBloc();

            // Si des données locales sont fournies, les utiliser directement (propriétaires)
            if (localPeriods != null) {
              bloc.add(LoadOccupationFromLocal(
                periods: localPeriods!,
                mode: mode,
                month: month,
                year: year,
              ));
            } else {
              // Sinon, charger depuis l'API (locataires)
              if (mode == OccupationCalendarMode.apartment) {
                bloc.add(LoadOccupation(
                  appartementId: appartementId!,
                  month: month,
                  year: year,
                ));
              } else {
                bloc.add(LoadOccupationForResidence(
                  residenceId: residenceId!,
                  appartementIds: appartementIds,
                  month: month,
                  year: year,
                ));
              }
            }

            return bloc;
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              TextSeed(
                mode == OccupationCalendarMode.apartment
                    ? 'Occupation de l\'appartement'
                    : 'Occupation de la résidence',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              Gap(Espacement.gapItem),
              TextSeed(
                'Cliquez sur une période occupée pour voir les détails',
                fontSize: 13,
                color: AppColors.textSecondary,
              ),

              Gap(Espacement.gapSection),

              // Calendrier (sans sélection)
              OccupationCalendar(
                mode: mode,
                enableSelection: false,
                onOccupiedPeriodTapped: (date) {
                  // Fermer le dialog et déclencher le callback
                  Navigator.pop(context);
                  if (onOccupiedPeriodTapped != null) {
                    onOccupiedPeriodTapped!(date);
                  }
                },
              ),

              Gap(Espacement.gapSection),

              // Bouton Fermer
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: TextSeed(
                    'Fermer',
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Affiche le dialog pour un appartement
  static Future<void> showForApartment({
    required BuildContext context,
    required int appartementId,
    Function(DateTime)? onOccupiedPeriodTapped,
    int? initialMonth,
    int? initialYear,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => OccupationCalendarDialog(
        mode: OccupationCalendarMode.apartment,
        appartementId: appartementId,
        onOccupiedPeriodTapped: onOccupiedPeriodTapped,
        initialMonth: initialMonth,
        initialYear: initialYear,
      ),
    );
  }

  /// Affiche le dialog pour une résidence
  static Future<void> showForResidence({
    required BuildContext context,
    required int residenceId,
    required List<int> appartementIds,
    Function(DateTime)? onOccupiedPeriodTapped,
    int? initialMonth,
    int? initialYear,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => OccupationCalendarDialog(
        mode: OccupationCalendarMode.residence,
        residenceId: residenceId,
        appartementIds: appartementIds,
        onOccupiedPeriodTapped: onOccupiedPeriodTapped,
        initialMonth: initialMonth,
        initialYear: initialYear,
      ),
    );
  }

  /// Affiche le dialog avec des données locales (pas d'appel API)
  /// Utilisé pour les propriétaires qui ont déjà les réservations en mémoire
  static Future<void> showWithLocalData({
    required BuildContext context,
    required List<OccupationPeriod> periods,
    required OccupationCalendarMode mode,
    Function(DateTime)? onOccupiedPeriodTapped,
    int? initialMonth,
    int? initialYear,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => OccupationCalendarDialog(
        mode: mode,
        localPeriods: periods,
        onOccupiedPeriodTapped: onOccupiedPeriodTapped,
        initialMonth: initialMonth,
        initialYear: initialYear,
      ),
    );
  }
}
