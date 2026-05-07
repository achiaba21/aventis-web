import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/occupation/occupation_calendar_mode.dart';
import 'package:asfar/model/occupation/occupation_period.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/appartement_wizard_screen.dart';
import 'package:asfar/screen/client/proprio/reservations/proprio_reservation_detail_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/helper/occupation_helper.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/detail_appart/appart_detail_content.dart';
import 'package:asfar/widget/detail_appart/appart_detail_header.dart';
import 'package:asfar/widget/detail_appart/proprio_appart_bottom_bar.dart';
import 'package:asfar/widget/dialog/occupation_calendar_dialog.dart';
import 'package:asfar/widget/dialog/reservation_selection_dialog.dart';

/// Page de détail d'un appartement pour le propriétaire
/// Réutilise les widgets communs avec la page locataire
///
/// PRINCIPE SOLID - Single Responsibility (S) :
/// Cet écran a une responsabilité unique : afficher les détails d'un appartement
/// Il écoute le BLoC pour toujours afficher la version la plus récente
class ProprioAppartDetailScreen extends StatelessWidget {
  const ProprioAppartDetailScreen(this.appartement, {super.key});

  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    // ✅ PRINCIPE SOLID - Open/Closed (O) :
    // Utiliser BlocBuilder pour écouter les changements du BLoC
    // sans modifier la structure existante du widget

    return BlocBuilder<AppartementBloc, AppartementState>(
      buildWhen: (previous, current) {
        // Rebuild uniquement pour les états qui contiennent des appartements
        return current is ProprietaireAppartementsLoaded ||
            current is AppartementOperationSuccess;
      },
      builder: (context, state) {
        // Récupérer l'appartement à jour depuis le state du BLoC
        Appartement currentAppartement = appartement;

        // Si le BLoC a des appartements chargés, chercher la version à jour
        if (state is ProprietaireAppartementsLoaded) {
          try {
            final updatedAppart = state.appartements.firstWhere(
              (a) => a.id == appartement.id,
            );
            currentAppartement = updatedAppart;
          } catch (e) {
            // Appartement non trouvé dans la liste, utiliser l'original
            currentAppartement = appartement;
          }
        } else if (state is AppartementOperationSuccess) {
          try {
            final updatedAppart = state.appartements.firstWhere(
              (a) => a.id == appartement.id,
            );
            currentAppartement = updatedAppart;
          } catch (e) {
            // Appartement non trouvé dans la liste, utiliser l'original
            currentAppartement = appartement;
          }
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          bottomNavigationBar: ProprioAppartBottomBar(
            appartement: currentAppartement,
            onEditPressed: () {
              pushScreen(
                context,
                AppartementWizardScreen.edit(editing: currentAppartement),
              );
            },
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppartDetailHeader(
                    appartement: currentAppartement,
                    showFavoriteButton: false,
                    showCalendarButton: true,
                    onCalendarPressed: () => _openOccupationCalendar(context, currentAppartement),
                  ),
                  AppartDetailContent(
                    appartement: currentAppartement,
                    showSejourSelector: false,
                    //showCancellationPolicy: true,
                    showHouseRules: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Ouvre le calendrier d'occupation pour l'appartement
  void _openOccupationCalendar(BuildContext context, Appartement appartement) {
    // Récupérer les réservations depuis le ReservationBloc
    final reservationState = context.read<ReservationBloc>().state;

    if (reservationState is ReservationLoaded) {
      // Utiliser les données locales (optimisation)
      final periods = OccupationHelper.reservationsToOccupationPeriods(
        reservationState.reservations,
        appartementId: appartement.id,
      );

      OccupationCalendarDialog.showWithLocalData(
        context: context,
        periods: periods,
        mode: OccupationCalendarMode.apartment,
        onOccupiedPeriodTapped: (date) {
          final periodsForDate = periods.where((p) => p.contains(date)).toList();
          _handleOccupiedPeriodTap(context, date, periodsForDate);
        },
      );
    } else {
      // Fallback sur l'API si les réservations ne sont pas chargées
      OccupationCalendarDialog.showForApartment(
        context: context,
        appartementId: appartement.id!,
        onOccupiedPeriodTapped: null, // Désactivé en mode fallback (pas de données locales)
      );
    }
  }

  /// Gère le tap sur une période occupée
  /// Si 1 période → Navigation directe
  /// Si N périodes → Affiche dialog de sélection
  Future<void> _handleOccupiedPeriodTap(
    BuildContext context,
    DateTime date,
    List<OccupationPeriod> periods,
  ) async {
    if (periods.isEmpty) return;

    OccupationPeriod? selectedPeriod;

    if (periods.length == 1) {
      // Une seule période → Navigation directe
      selectedPeriod = periods.first;
    } else {
      // Plusieurs périodes → Afficher dialog de sélection
      selectedPeriod = await ReservationSelectionDialog.show(
        context: context,
        periods: periods,
        selectedDate: date,
      );
    }

    if (selectedPeriod == null || selectedPeriod.reservationId == null) return;

    if (!context.mounted) return; // Vérifier si le contexte est toujours valide

    // Récupérer la réservation depuis ReservationBloc
    final reservationState = context.read<ReservationBloc>().state;
    if (reservationState is! ReservationLoaded) return;

    try {
      final reservation = reservationState.reservations.firstWhere(
        (r) => r.id == selectedPeriod!.reservationId,
      );

      if (!context.mounted) return; // Vérifier à nouveau avant la navigation

      pushScreen(context, ProprioReservationDetailScreen(reservation));
    } catch (e) {
      // Réservation non trouvée, ne rien faire
      return;
    }
  }
}
