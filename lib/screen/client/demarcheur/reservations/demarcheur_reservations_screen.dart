import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_bloc.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_event.dart';
import 'package:asfar/bloc/demarcheur_bloc/demarcheur_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/demarcheur/profile/demarcheur_profile_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/input/number_input_formatter.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Écran listant les réservations soumises par le démarcheur
class DemarcheurReservationsScreen extends StatefulWidget {
  const DemarcheurReservationsScreen({super.key});

  @override
  State<DemarcheurReservationsScreen> createState() =>
      _DemarcheurReservationsScreenState();
}

class _DemarcheurReservationsScreenState
    extends State<DemarcheurReservationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DemarcheurBloc>().add(LoadDemarcheurReservations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextSeed(
          "Mes réservations",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () => context
                .read<DemarcheurBloc>()
                .add(LoadDemarcheurReservations()),
            icon: const Icon(Icons.refresh),
            color: AppColors.accent,
            tooltip: "Rafraîchir",
          ),
          IconButton(
            onPressed: () => pushScreen(context, const DemarcheurProfileScreen()),
            icon: const Icon(Icons.person_outline),
            color: AppColors.accent,
            tooltip: "Profil",
          ),
        ],
      ),
      body: BlocBuilder<DemarcheurBloc, DemarcheurState>(
        builder: (context, state) {
          if (state is DemarcheurLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DemarcheurError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    TextSeed(
                      state.message,
                      color: AppColors.textMuted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context
                          .read<DemarcheurBloc>()
                          .add(LoadDemarcheurReservations()),
                      child: const Text("Réessayer"),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DemarcheurReservationsLoaded) {
            if (state.reservations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy,
                          size: 64, color: AppColors.inactive),
                      const SizedBox(height: 16),
                      TextSeed(
                        "Aucune réservation pour le moment",
                        fontSize: 16,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextSeed(
                        "Prospectez un client via le calendrier d'un appartement.",
                        fontSize: 13,
                        color: AppColors.textMuted,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final sorted = List.of(state.reservations)
              ..sort((a, b) => (b.createdAt ?? DateTime.now())
                  .compareTo(a.createdAt ?? DateTime.now()));

            return ListView.separated(
              padding: EdgeInsets.all(Espacement.paddingBloc),
              itemCount: sorted.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: Espacement.gapSection),
              itemBuilder: (context, index) =>
                  _ReservationCard(reservation: sorted[index]),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;

  const _ReservationCard({required this.reservation});

  Color get _statusColor {
    switch (reservation.statut) {
      case ReservationStatus.confirmee:
        return AppColors.success;
      case ReservationStatus.annulee:
        return AppColors.error;
      case ReservationStatus.enAttente:
        return AppColors.warning;
      default:
        return AppColors.textMuted;
    }
  }

  String get _statusLabel {
    switch (reservation.statut) {
      case ReservationStatus.confirmee:
        return "Confirmée";
      case ReservationStatus.annulee:
        return "Annulée";
      case ReservationStatus.enAttente:
        return "En attente";
      default:
        return reservation.statut?.name ?? "Inconnu";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextSeed(
                reservation.reference ?? "—",
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withValues(alpha: 0.5)),
                ),
                child: TextSeed(
                  _statusLabel,
                  fontSize: 12,
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (reservation.debut != null)
            _InfoRow(
              icon: Icons.calendar_today,
              label: "Arrivée",
              value:
                  "${reservation.debut!.day}/${reservation.debut!.month}/${reservation.debut!.year}",
            ),
          if (reservation.debut != null && reservation.fin != null)
            _InfoRow(
              icon: Icons.timer_outlined,
              label: "Durée",
              value: () {
                final d = reservation.fin!.difference(reservation.debut!).inDays;
                return "$d jour${d > 1 ? 's' : ''}";
              }(),
            ),
          if (reservation.prix != null)
            _InfoRow(
              icon: Icons.payments_outlined,
              label: "Montant",
              value: "${NumberInputFormatter.formatAmount(reservation.prix!)} FCFA",
            ),
          if (reservation.montantCommission != null && reservation.montantCommission! > 0)
            _InfoRow(
              icon: Icons.handshake_outlined,
              label: "Commission",
              value: "${NumberInputFormatter.formatAmount(reservation.montantCommission!)} FCFA",
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          TextSeed("$label : ", fontSize: 13, color: AppColors.textMuted),
          TextSeed(value, fontSize: 13),
        ],
      ),
    );
  }
}
