import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/bloc/charge_bloc/charge_bloc.dart';
import 'package:asfar/bloc/charge_bloc/charge_event.dart';
import 'package:asfar/bloc/charge_bloc/charge_state.dart';
import 'package:asfar/bloc/comptabilite_filter/comptabilite_filter_cubit.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/comptabilite_loaded_view.dart';
import 'package:asfar/screen/client/proprio/comptabilite/widget/comptabilite_views.dart';
import 'package:asfar/screen/client/proprio/comptabilite/charge_form_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ComptabiliteScreen extends StatefulWidget {
  const ComptabiliteScreen({super.key});

  @override
  State<ComptabiliteScreen> createState() => _ComptabiliteScreenState();
}

class _ComptabiliteScreenState extends State<ComptabiliteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _injectResidencesAndLoadCharges();
    });
  }

  void _injectResidencesAndLoadCharges() {
    final appartementState = context.read<AppartementBloc>().state;
    context.read<ChargeBloc>().setAppartements(appartementState.appartements);
    context.read<ChargeBloc>().add(LoadCharges());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextSeed(
          "Comptabilité",
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ChargeBloc>().add(RefreshCharges());
            },
            icon: const Icon(Icons.refresh),
            tooltip: "Actualiser",
            color: AppColors.accent,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddChargeDialog(context),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: AppColors.textOnAccent),
        label: TextSeed(
          "Ajouter charge",
          color: AppColors.textOnAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: BlocListener<ChargeBloc, ChargeState>(
        listener: (context, state) {
          if (state is ChargeOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is ChargeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: BlocBuilder<ChargeBloc, ChargeState>(
          builder: (context, chargeState) {
            return BlocBuilder<AppartementBloc, AppartementState>(
              builder: (context, appartementState) {
                return BlocBuilder<ReservationBloc, ReservationState>(
                  builder: (context, reservationState) {
                    return BlocBuilder<ComptabiliteFilterCubit, ComptabiliteFilterState>(
                      builder: (context, filterState) {
                        final appartements = appartementState.appartements;

                        final reservations = reservationState is ReservationLoaded
                            ? reservationState.reservations
                            : <Reservation>[];

                        final charges = chargeState is ChargeLoaded
                            ? chargeState.charges
                            : <Charge>[];

                        if (chargeState is ChargeLoading) {
                          return const ComptabiliteLoadingView();
                        }

                        if (chargeState is ChargeError) {
                          return ComptabiliteErrorView(message: chargeState.message);
                        }

                        if (appartements.isEmpty) {
                          return const ComptabiliteEmptyView();
                        }

                        return ComptabiliteLoadedView(
                          appartements: appartements,
                          reservations: reservations,
                          charges: charges,
                          filterState: filterState,
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showAddChargeDialog(BuildContext context) {
    final appartementState = context.read<AppartementBloc>().state;
    if (appartementState.appartements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vous devez d'abord créer un appartement"),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    pushScreen(context, const ChargeFormScreen());
  }
}
