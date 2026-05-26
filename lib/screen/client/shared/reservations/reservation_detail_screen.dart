import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_bloc.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_event.dart';
import 'package:asfar/bloc/reservation_detail_bloc/reservation_detail_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/reservation/reservation_detail_action.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_contact_sheet.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_edit_manuelle_screen.dart';
import 'package:asfar/screen/client/shared/reservations/reservation_scan_screen.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_actions_bar.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_amounts_section.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_appart_card.dart';
import 'package:asfar/model/reservation/reservation_manuelle.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_apporteur_externe_card.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_demarcheur_card.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_error_view.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_header.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_loading_view.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_party_card.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_qr_section.dart';
import 'package:asfar/screen/client/shared/reservations/widget/reservation_detail_timeline.dart';
import 'package:asfar/widget/section/section_with_eyebrow.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/theme/app_text_styles.dart';
import 'package:asfar/util/calc/reservation_actions_resolver.dart';
import 'package:asfar/util/calc/reservation_contact_resolver.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';

/// Page de détail d'une réservation — surface transverse multi-rôle.
///
/// 2 modes d'init :
/// - `ReservationDetailScreen(reservation: ...)` : objet déjà en main (cache
///   instantané depuis une row, card, etc.)
/// - `ReservationDetailScreen.byReference(reference: ...)` : deep-link via
///   référence seule (push notif, card chat).
///
/// Le contenu et les actions sont adaptés au rôle du viewer (locataire,
/// proprio, démarcheur) et au statut courant via `ReservationActionsResolver`.
class ReservationDetailScreen extends StatelessWidget {
  final Reservation? reservation;
  final String? reference;
  final ReservationViewerRole? viewerRole;

  const ReservationDetailScreen({
    super.key,
    required this.reservation,
    this.viewerRole,
  }) : reference = null;

  const ReservationDetailScreen.byReference({
    super.key,
    required String this.reference,
    this.viewerRole,
  }) : reservation = null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReservationDetailBloc>(
      create: (ctx) {
        final bloc = ReservationDetailBloc(
          listBloc: ctx.read<ReservationBloc>(),
        );
        if (reservation != null) {
          bloc.add(LoadFromObject(reservation!));
        } else if (reference != null) {
          bloc.add(LoadByReference(reference!));
        }
        return bloc;
      },
      child: _ReservationDetailView(viewerRole: viewerRole),
    );
  }
}

class _ReservationDetailView extends StatelessWidget {
  final ReservationViewerRole? viewerRole;

  const _ReservationDetailView({this.viewerRole});

  ReservationViewerRole _resolveRole(BuildContext context) {
    if (viewerRole != null) return viewerRole!;
    final user = context.read<UserBloc>().state.user;
    final type = (user?.type ?? '').toLowerCase();
    switch (type) {
      case 'proprietaire':
        return ReservationViewerRole.proprietaire;
      case 'demarcheur':
        return ReservationViewerRole.demarcheur;
      case 'locataire':
      default:
        return ReservationViewerRole.locataire;
    }
  }

  void _onActionResult(BuildContext context, ReservationDetailState state) {
    if (state is ReservationDetailActionSuccess) {
      final label = _successLabelOf(state.action);
      if (label != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(label),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
    if (state is ReservationDetailActionError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(state.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.danger,
      ));
    }
  }

  String? _successLabelOf(ReservationDetailAction action) {
    switch (action) {
      case ReservationDetailAction.cancel:
        return 'Réservation annulée';
      case ReservationDetailAction.pay:
        return 'Paiement effectué';
      case ReservationDetailAction.confirm:
        return 'Réservation confirmée';
      case ReservationDetailAction.refuse:
        return 'Réservation refusée';
      case ReservationDetailAction.scanQr:
        return 'Réservation finalisée';
      case ReservationDetailAction.edit:
        return 'Réservation mise à jour';
      case ReservationDetailAction.viewQr:
      case ReservationDetailAction.contact:
        return null;
    }
  }

  Future<void> _onAction(
    BuildContext context,
    ReservationDetailAction action,
    Reservation reservation,
    ReservationViewerRole role,
  ) async {
    final bloc = context.read<ReservationDetailBloc>();
    switch (action) {
      case ReservationDetailAction.contact:
        final target = ReservationContactResolver.targetFor(role, reservation);
        if (target != null) {
          await ReservationContactSheet.show(context, target);
        }
        return;
      case ReservationDetailAction.scanQr:
        final code = await pushScreen<String>(
          context,
          const ReservationScanScreen(),
        );
        if (code != null && code.isNotEmpty) {
          bloc.add(PerformAction(
            ReservationDetailAction.scanQr,
            secretKey: code,
          ));
        }
        return;
      case ReservationDetailAction.edit:
        await pushScreen(
          context,
          BlocProvider<ReservationDetailBloc>.value(
            value: bloc,
            child: ReservationEditManuelleScreen(reservation: reservation),
          ),
        );
        return;
      case ReservationDetailAction.viewQr:
        return;
      case ReservationDetailAction.cancel:
      case ReservationDetailAction.refuse:
        final motif = await _askMotif(context, action);
        if (motif == null) return;
        bloc.add(PerformAction(action, motif: motif));
        return;
      case ReservationDetailAction.pay:
      case ReservationDetailAction.confirm:
        bloc.add(PerformAction(action));
        return;
    }
  }

  Future<String?> _askMotif(
    BuildContext context,
    ReservationDetailAction action,
  ) async {
    final ctrl = TextEditingController();
    final isCancel = action == ReservationDetailAction.cancel;
    final title = isCancel ? 'Annuler la réservation' : 'Refuser la réservation';
    return showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.bgElev1,
        title: Text(title, style: AppTextStyles.h3),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.text),
          decoration: const InputDecoration(
            hintText: 'Motif (optionnel)',
            hintStyle: TextStyle(color: AppColors.text3),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Retour', style: TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(ctrl.text.trim()),
            child: Text(
              isCancel ? 'Annuler' : 'Refuser',
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Détail réservation',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
      ),
      body: BlocConsumer<ReservationDetailBloc, ReservationDetailState>(
        listener: _onActionResult,
        builder: (context, state) {
          final reservation = state.reservation;

          if (reservation == null) {
            if (state is ReservationDetailError) {
              return ReservationDetailErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<ReservationDetailBloc>().add(RefreshFromApi()),
              );
            }
            return const ReservationDetailLoadingView();
          }

          final role = _resolveRole(context);

          return SafeArea(
            top: false,
            child: _ReservationDetailBody(
              reservation: reservation,
              role: role,
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<ReservationDetailBloc,
          ReservationDetailState>(
        builder: (context, state) {
          final reservation = state.reservation;
          if (reservation == null) return const SizedBox.shrink();
          final role = _resolveRole(context);
          final actions = ReservationActionsResolver.actionsFor(
            role: role,
            reservation: reservation,
          );
          final actionInProgress = state is ReservationDetailActionInProgress
              ? state.action
              : null;
          return ReservationDetailActionsBar(
            actions: actions,
            actionInProgress: actionInProgress,
            onAction: (a) => _onAction(context, a, reservation, role),
          );
        },
      ),
    );
  }
}

class _ReservationDetailBody extends StatelessWidget {
  final Reservation reservation;
  final ReservationViewerRole role;

  const _ReservationDetailBody({
    required this.reservation,
    required this.role,
  });

  bool get _shouldShowQr {
    if (role != ReservationViewerRole.locataire) return false;
    final s = reservation.statut;
    return s == ReservationStatus.payee ||
        s == ReservationStatus.finalisee;
  }

  bool get _shouldShowDemarcheur {
    return role == ReservationViewerRole.proprietaire &&
        ReservationContactResolver.demarcheurTargetFor(reservation) != null;
  }

  bool get _shouldShowApporteurExterne {
    if (role != ReservationViewerRole.proprietaire) return false;
    final r = reservation;
    return r is ReservationManuelle && r.hasApporteurExterne;
  }

  @override
  Widget build(BuildContext context) {
    final partyTarget = ReservationContactResolver.targetFor(role, reservation);
    final code = reservation.codeReservation;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReservationDetailHeader(reservation: reservation),
          const SizedBox(height: 24),
          SectionWithEyebrow(
            label: 'LOGEMENT',
            child: ReservationDetailAppartCard(appart: reservation.appart),
          ),
          const SizedBox(height: 24),
          SectionWithEyebrow(
            label: 'MONTANTS',
            child: ReservationDetailAmountsSection(reservation: reservation),
          ),
          if (partyTarget != null) ...[
            const SizedBox(height: 24),
            SectionWithEyebrow(
              label: partyTarget.roleLabel.toUpperCase(),
              child: ReservationDetailPartyCard(target: partyTarget),
            ),
          ],
          if (_shouldShowDemarcheur) ...[
            const SizedBox(height: 24),
            SectionWithEyebrow(
              label: 'DÉMARCHEUR SOURCE',
              child: ReservationDetailDemarcheurCard(reservation: reservation),
            ),
          ],
          if (_shouldShowApporteurExterne) ...[
            const SizedBox(height: 24),
            SectionWithEyebrow(
              label: "APPORTEUR D'AFFAIRES",
              child: ReservationDetailApporteurExterneCard(
                reservation: reservation as ReservationManuelle,
              ),
            ),
          ],
          if (_shouldShowQr && code?.secretKey != null) ...[
            const SizedBox(height: 24),
            SectionWithEyebrow(
              label: "CODE D'ACCÈS",
              child: ReservationDetailQrSection(
                secretKey: code!.secretKey!,
                reference: reservation.reference ?? '',
              ),
            ),
          ],
          const SizedBox(height: 24),
          SectionWithEyebrow(
            label: 'HISTORIQUE',
            child: ReservationDetailTimeline(reservation: reservation),
          ),
        ],
      ),
    );
  }
}
