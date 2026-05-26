import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_bloc.dart';
import 'package:asfar/bloc/calendar_plage_bloc/calendar_plage_state.dart';
import 'package:asfar/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_bloc.dart';
import 'package:asfar/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_event.dart';
import 'package:asfar/bloc/manual_reservation_wizard_bloc/manual_reservation_wizard_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/model/calendar/calendar_plage.dart';
import 'package:asfar/model/enumeration/moyen_paiement.dart';
import 'package:asfar/model/enumeration/reservation_manuelle_source.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/wizard_cta_bar.dart';
import 'package:asfar/screen/client/proprio/appartements/wizard/widget/wizard_step_indicator.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/step_client_info.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/step_confirmation.dart';
import 'package:asfar/screen/client/proprio/calendrier/widget/step_dates.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/button_size.dart';
import 'package:asfar/widget/button/custom_button.dart';

/// Wizard de création de réservation manuelle (3 étapes).
///
/// - Step 1 : sélection date range sur calendrier mensuel.
/// - Step 2 : nom + téléphone + source + paiement + récap montant.
/// - Step 3 : confirmation (success circle + récap final + CTA retour).
///
/// Le BLoC local est créé pour la durée du wizard et délègue la création API
/// à `ReservationBloc.CreateManualReservation`.
class ManualReservationWizardScreen extends StatelessWidget {
  final Appartement appartement;
  final DateTime? initialDebut;
  final DateTime? initialFin;

  const ManualReservationWizardScreen({
    super.key,
    required this.appartement,
    this.initialDebut,
    this.initialFin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ManualReservationWizardBloc>(
      create: (ctx) => ManualReservationWizardBloc(
        reservationBloc: ctx.read<ReservationBloc>(),
        plages: _readCurrentPlages(ctx),
      )..add(InitManualReservationWizard(
          appartement: appartement,
          initialDebut: initialDebut,
          initialFin: initialFin,
        )),
      child: _ManualReservationWizardView(),
    );
  }

  static List<CalendarPlage> _readCurrentPlages(BuildContext ctx) {
    final state = ctx.read<CalendarPlageBloc>().state;
    if (state is CalendarPlagesLoaded) return state.plages;
    return const [];
  }
}

class _ManualReservationWizardView extends StatelessWidget {
  void _onBack(BuildContext context, ManualReservationWizardState state) {
    if (state.currentStep > 1 && state.currentStep < 3) {
      context.read<ManualReservationWizardBloc>().add(PrevWizardStep());
    } else {
      back(context);
    }
  }

  void _onContinue(BuildContext context, ManualReservationWizardState state) {
    if (state.currentStep == 1) {
      context.read<ManualReservationWizardBloc>().add(NextWizardStep());
    } else if (state.currentStep == 2) {
      context.read<ManualReservationWizardBloc>().add(PublishReservation());
    } else {
      back(context);
    }
  }

  bool _canNext(ManualReservationWizardState state) {
    switch (state.currentStep) {
      case 1:
        return state.debut != null && state.fin != null;
      case 2:
        return (state.nomClient ?? '').trim().isNotEmpty &&
            (state.telephoneClient ?? '').trim().isNotEmpty &&
            state.source != null &&
            state.moyenPaiement != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MultiBlocListener(
        listeners: [
          BlocListener<ReservationBloc, ReservationState>(
            listenWhen: (prev, curr) => curr is ReservationManuelleCreated,
            listener: (context, state) {
              if (state is ReservationManuelleCreated) {
                context
                    .read<ManualReservationWizardBloc>()
                    .add(ReservationCreatedSuccess(state.reservation));
              }
            },
          ),
          BlocListener<ManualReservationWizardBloc,
              ManualReservationWizardState>(
            listenWhen: (prev, curr) =>
                prev.errorMessage != curr.errorMessage &&
                curr.errorMessage != null,
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.errorMessage ?? 'Erreur'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.danger,
              ));
            },
          ),
          // Tient `wizardBloc.plages` à jour quand le calendrier parent
          // termine de charger (cas init : Loading → Loaded après création
          // du wizard) ou rafraîchit (refresh post-publish, etc.).
          BlocListener<CalendarPlageBloc, CalendarPlageState>(
            listener: (context, state) {
              if (state is CalendarPlagesLoaded) {
                context.read<ManualReservationWizardBloc>().plages =
                    state.plages;
              }
            },
          ),
        ],
        child: BlocBuilder<ManualReservationWizardBloc,
            ManualReservationWizardState>(
          builder: (context, state) {
            final isFinal = state.currentStep == 3;
            return SafeArea(
              child: Column(
                children: [
                  WizardStepIndicator(
                    currentStep: state.currentStep,
                    totalSteps: state.totalSteps,
                    title: 'Nouvelle réservation',
                    onBack: () => _onBack(context, state),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.fromLTRB(18, 0, 18, 24),
                      child: _StepContent(
                        state: state,
                        onUpdateRange: (d, f) {
                          final bloc =
                              context.read<ManualReservationWizardBloc>();
                          bloc.add(UpdateWizardField('debut', d));
                          bloc.add(UpdateWizardField('fin', f));
                        },
                        onNomChange: (v) => context
                            .read<ManualReservationWizardBloc>()
                            .add(UpdateWizardField('nomClient', v)),
                        onTelChange: (v) => context
                            .read<ManualReservationWizardBloc>()
                            .add(UpdateWizardField('telephoneClient', v)),
                        onSourceChange: (v) => context
                            .read<ManualReservationWizardBloc>()
                            .add(UpdateWizardField('source', v)),
                        onPaiementChange: (v) => context
                            .read<ManualReservationWizardBloc>()
                            .add(UpdateWizardField('moyenPaiement', v)),
                        onApporteurNomChange: (v) => context
                            .read<ManualReservationWizardBloc>()
                            .add(UpdateWizardField('apporteurNom', v)),
                        onApporteurTelChange: (v) => context
                            .read<ManualReservationWizardBloc>()
                            .add(UpdateWizardField('apporteurTelephone', v)),
                        onCommissionChange: (v) => context
                            .read<ManualReservationWizardBloc>()
                            .add(UpdateWizardField('montantCommission', v)),
                      ),
                    ),
                  ),
                  if (isFinal)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                      child: CustomButton(
                        text: 'Retour au calendrier',
                        onPressed: () => back(context),
                        size: ButtonSize.lg,
                        block: true,
                      ),
                    )
                  else
                    WizardCtaBar(
                      currentStep: state.currentStep,
                      totalSteps: 2,
                      canNext: _canNext(state),
                      isPublishing: state.isPublishing,
                      onContinue: () => _onContinue(context, state),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StepContent extends StatelessWidget {
  final ManualReservationWizardState state;
  final void Function(DateTime? debut, DateTime? fin) onUpdateRange;
  final void Function(String) onNomChange;
  final void Function(String) onTelChange;
  final ValueChanged<ReservationManuelleSource?> onSourceChange;
  final ValueChanged<MoyenPaiement> onPaiementChange;
  final void Function(String) onApporteurNomChange;
  final void Function(String) onApporteurTelChange;
  final void Function(double?) onCommissionChange;

  const _StepContent({
    required this.state,
    required this.onUpdateRange,
    required this.onNomChange,
    required this.onTelChange,
    required this.onSourceChange,
    required this.onPaiementChange,
    required this.onApporteurNomChange,
    required this.onApporteurTelChange,
    required this.onCommissionChange,
  });

  @override
  Widget build(BuildContext context) {
    switch (state.currentStep) {
      case 1:
        // BlocBuilder pour rebuild quand les plages chargent (cas init :
        // Loading → Loaded après création du wizard).
        return BlocBuilder<CalendarPlageBloc, CalendarPlageState>(
          builder: (context, plageState) {
            final plages = plageState is CalendarPlagesLoaded
                ? plageState.plages
                : <CalendarPlage>[];
            return StepDates(
              selectedStart: state.debut,
              selectedEnd: state.fin,
              plages: plages,
              onRangeChange: onUpdateRange,
            );
          },
        );
      case 2:
        final prix = (state.appartement?.prix ?? 0).round();
        return StepClientInfo(
          initialNom: state.nomClient,
          initialTel: state.telephoneClient,
          initialApporteurNom: state.apporteurNom,
          initialApporteurTel: state.apporteurTelephone,
          initialMontantCommission: state.montantCommission,
          source: state.source,
          moyenPaiement: state.moyenPaiement,
          nbNuits: state.nbNuits,
          prixNuit: prix,
          totalClient: state.totalClient.round(),
          totalRecuProprio: state.totalRecuProprio.round(),
          onNomChange: onNomChange,
          onTelChange: onTelChange,
          onApporteurNomChange: onApporteurNomChange,
          onApporteurTelChange: onApporteurTelChange,
          onCommissionChange: onCommissionChange,
          onSourceChange: onSourceChange,
          onPaiementChange: onPaiementChange,
          errors: state.errors,
        );
      case 3:
        if (state.created == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        return StepConfirmation(
          reservation: state.created!,
          clientNom: state.nomClient ?? 'Le client',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
