import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/comptabilite_filter/comptabilite_filter_cubit.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/alertes_section.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/appartement_selector.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/charge_list_section.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/dashboard_cards.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/evolution_chart.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/periode_selector.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/repartition_ca_chart.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/view_mode_toggle.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charge_detail_screen.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charge_form_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/comptabilite_calculator.dart'
    show ComptabiliteCalculator, PointEvolution, RepartitionCaItem;
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/carousel/carousel_widget.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Vue principale quand les données comptabilité sont chargées.
///
/// Note : depuis BACKEND-FLAT-APPART, le filtre par résidence n'existe plus.
/// Le mode `parResidence` du filterState est conservé pour compatibilité
/// mais affiche systématiquement la répartition par appartement.
class ComptabiliteLoadedView extends StatelessWidget {
  final List<Appartement> appartements;
  final List<Reservation> reservations;
  final List<Charge> charges;
  final ComptabiliteFilterState filterState;

  const ComptabiliteLoadedView({
    super.key,
    required this.appartements,
    required this.reservations,
    required this.charges,
    required this.filterState,
  });

  @override
  Widget build(BuildContext context) {
    final isAppartementMode = filterState.isAppartementMode;
    final allAppartements = appartements;

    final metrics = _calculateMetrics(allAppartements);

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChargeBloc>().add(RefreshCharges());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(Espacement.paddingBloc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ViewModeToggle(
              isAppartementMode: isAppartementMode,
              onModeChanged: (parAppartement) {
                context.read<ComptabiliteFilterCubit>().changeViewMode(
                  parAppartement
                      ? ComptabiliteViewMode.parAppartement
                      : ComptabiliteViewMode.parResidence,
                );
              },
            ),
            const SizedBox(height: 16),
            if (isAppartementMode) ...[
              const SizedBox(height: 12),
              AppartementSelector(
                appartements: allAppartements,
                selectedAppartementId: filterState.selectedAppartementId,
                enabled: true,
                onSelected: (appartementId) {
                  context.read<ComptabiliteFilterCubit>().selectAppartement(appartementId);
                },
              ),
            ],
            const SizedBox(height: 16),
            PeriodeSelector(
              dateDebut: filterState.dateDebut,
              dateFin: filterState.dateFin,
              onPeriodeChanged: (debut, fin) {
                context.read<ComptabiliteFilterCubit>().selectPeriode(debut, fin);
              },
            ),
            const SizedBox(height: 24),
            DashboardCards(
              chiffreAffaires: metrics.ca,
              totalCharges: metrics.totalCharges,
              beneficeNet: metrics.benefice,
              margePourcent: metrics.marge,
              tauxOccupation: metrics.tauxOccupation,
              prixMoyenAppartements: metrics.prixMoyenAppartements,
              nombreReservations: metrics.nombreReservations,
              nombreCharges: metrics.chargesFiltrees.length,
            ),
            const SizedBox(height: 24),
            if (metrics.alertes.isNotEmpty) ...[
              AlertesSection(alertes: metrics.alertes),
              const SizedBox(height: 24),
            ],
            CarouselWidget(
              items: [
                if (metrics.historique.isNotEmpty)
                  CarouselItem(
                    label: "Évolution",
                    child: EvolutionChart(historique: metrics.historique),
                  ),
                if (filterState.selectedAppartementId == null)
                  CarouselItem(
                    label: "Répartition",
                    child: RepartitionCaChart(
                      items: metrics.repartitionCa,
                      title: "Répartition CA par appartement",
                      isAppartementMode: true,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            ChargeListSection(
              charges: metrics.chargesFiltrees,
              onTap: (charge) => _showChargeDetail(context, charge),
              onEdit: (charge) => _editCharge(context, charge),
              onDelete: (charge) => _deleteCharge(context, charge),
              onMarkPaid: (charge) => _markAsPaid(context, charge),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  _ComptabiliteMetrics _calculateMetrics(List<Appartement> allAppartements) {
    final ca = ComptabiliteCalculator.chiffreAffaires(
      reservations: reservations,
      dateDebut: filterState.dateDebut,
      dateFin: filterState.dateFin,
      appartementId: filterState.selectedAppartementId,
      appartements: allAppartements,
    );

    final chargesFiltrees = ComptabiliteCalculator.filtrerCharges(
      charges: charges,
      dateDebut: filterState.dateDebut,
      dateFin: filterState.dateFin,
      appartementId: filterState.selectedAppartementId,
    );

    final totalCharges = chargesFiltrees.fold(0.0, (sum, c) => sum + (c.montant ?? 0));
    final benefice = ComptabiliteCalculator.beneficeNet(
      chiffreAffaires: ca,
      totalCharges: totalCharges,
    );
    final marge = ComptabiliteCalculator.margePourcent(
      chiffreAffaires: ca,
      beneficeNet: benefice,
    );

    final nombreReservations = ComptabiliteCalculator.nombreReservations(
      reservations: reservations,
      dateDebut: filterState.dateDebut,
      dateFin: filterState.dateFin,
      appartementId: filterState.selectedAppartementId,
      appartements: allAppartements,
    );

    final tauxOccupation = ComptabiliteCalculator.tauxOccupation(
      reservations: reservations,
      appartements: allAppartements,
      dateDebut: filterState.dateDebut,
      dateFin: filterState.dateFin,
      appartementId: filterState.selectedAppartementId,
    );

    final prixMoyenAppartements =
        ComptabiliteCalculator.prixMoyenAppartements(allAppartements);

    final alertes = ComptabiliteCalculator.chargesAvecAlertes(chargesFiltrees);

    final historique = ComptabiliteCalculator.historiqueMensuel(
      reservations: reservations,
      charges: charges,
      nombreMois: 6,
      appartementId: filterState.selectedAppartementId,
      appartements: allAppartements,
    );

    final repartitionCa = ComptabiliteCalculator.repartitionCaParAppartement(
      reservations: reservations,
      appartements: allAppartements,
      dateDebut: filterState.dateDebut,
      dateFin: filterState.dateFin,
    );

    return _ComptabiliteMetrics(
      ca: ca,
      totalCharges: totalCharges,
      benefice: benefice,
      marge: marge,
      nombreReservations: nombreReservations,
      tauxOccupation: tauxOccupation,
      prixMoyenAppartements: prixMoyenAppartements,
      chargesFiltrees: chargesFiltrees,
      alertes: alertes,
      historique: historique,
      repartitionCa: repartitionCa,
    );
  }

  void _showChargeDetail(BuildContext context, Charge charge) {
    pushScreen(context, ChargeDetailScreen(charge: charge));
  }

  void _editCharge(BuildContext context, Charge charge) {
    pushScreen(context, ChargeFormScreen(chargeToEdit: charge));
  }

  void _deleteCharge(BuildContext context, Charge charge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.background,
        title: TextSeed(
          "Supprimer la charge ?",
          fontWeight: FontWeight.bold,
        ),
        content: TextSeed(
          "Cette action est irréversible. La charge \"${charge.labelComplet}\" sera définitivement supprimée.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: TextSeed("Annuler", color: AppColors.textMuted),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChargeBloc>().add(
                    DeleteCharge(chargeId: charge.id!),
                  );
            },
            child: TextSeed("Supprimer", color: AppColors.error),
          ),
        ],
      ),
    );
  }

  void _markAsPaid(BuildContext context, Charge charge) {
    context.read<ChargeBloc>().add(
          MarkChargeAsPaid(chargeId: charge.id!),
        );
  }
}

/// Classe interne pour regrouper les métriques calculées
class _ComptabiliteMetrics {
  final double ca;
  final double totalCharges;
  final double benefice;
  final double marge;
  final int nombreReservations;
  final double tauxOccupation;
  final double prixMoyenAppartements;
  final List<Charge> chargesFiltrees;
  final List<Charge> alertes;
  final List<PointEvolution> historique;
  final List<RepartitionCaItem> repartitionCa;

  _ComptabiliteMetrics({
    required this.ca,
    required this.totalCharges,
    required this.benefice,
    required this.marge,
    required this.nombreReservations,
    required this.tauxOccupation,
    required this.prixMoyenAppartements,
    required this.chargesFiltrees,
    required this.alertes,
    required this.historique,
    required this.repartitionCa,
  });
}
