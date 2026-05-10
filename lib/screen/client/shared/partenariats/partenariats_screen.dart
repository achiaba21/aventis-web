import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_event.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/model/partenariat/demande_partenariat.dart';
import 'package:asfar/screen/client/shared/partenariats/widget/partenariats_list_card.dart';
import 'package:asfar/screen/client/shared/partenariats/widget/partenariats_loading_view.dart';
import 'package:asfar/screen/client/shared/partenariats/widget/send_demande_dialog.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/appbar/dynamic_appbar.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/feedback/empty_state.dart';

/// Écran « Mes partenariats » — transverse démarcheur/proprio.
///
/// V9.6 : adapte son contenu selon `user.type`.
/// - Démarcheur : voit les demandes ENVOYÉES vers les proprios.
///   FAB « Nouvelle demande » qui ouvre `SendDemandeDialog` puis dispatche
///   `EnvoyerDemande(telephone)`.
/// - Propriétaire : voit les demandes REÇUES de démarcheurs.
///   Actions Accepter / Refuser par ligne pour les demandes en attente.
///
/// L'écran est accessible via le settings card du profil (V9.5).
class PartenariatsScreen extends StatefulWidget {
  const PartenariatsScreen({super.key});

  @override
  State<PartenariatsScreen> createState() => _PartenariatsScreenState();
}

class _PartenariatsScreenState extends State<PartenariatsScreen> {
  bool get _isOwner {
    final type =
        (context.read<UserBloc>().state.user?.type ?? '').toLowerCase();
    return type == 'proprietaire';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDemandes();
    });
  }

  void _loadDemandes() {
    final bloc = context.read<PartenariatBloc>();
    if (_isOwner) {
      bloc.add(const LoadDemandesRecues());
    } else {
      bloc.add(const LoadDemandesEnvoyees());
    }
  }

  Future<void> _onSendDemande() async {
    final bloc = context.read<PartenariatBloc>();
    final messenger = ScaffoldMessenger.of(context);
    final phone = await SendDemandeDialog.show(context);
    if (phone == null) return;
    bloc.add(EnvoyerDemande(phone));
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Demande envoyée'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onAccept(DemandePartenariat d) {
    context.read<PartenariatBloc>().add(AccepterDemande(d.id));
    _toast('Demande acceptée');
  }

  void _onRefuse(DemandePartenariat d) {
    context.read<PartenariatBloc>().add(RefuserDemande(d.id));
    _toast('Demande refusée');
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<DemandePartenariat> _extractDemandes(PartenariatState state) {
    if (state is DemandesEnvoyeesLoaded) return state.demandes;
    if (state is DemandesRecuesLoaded) return state.demandes;
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _isOwner;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DynamicAppBar(
        title: 'Mes partenariats',
        leading: IconBoutton(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => back(context),
        ),
        trailing: isOwner
            ? null
            : IconBoutton(
                icon: Icons.add,
                onPressed: _onSendDemande,
              ),
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<PartenariatBloc, PartenariatState>(
          builder: (context, state) {
            if (state is PartenariatLoading) {
              return const PartenariatsLoadingView();
            }
            if (state is PartenariatError) {
              return EmptyState.error(
                message: state.message,
                onRetry: _loadDemandes,
              );
            }
            final demandes = _extractDemandes(state);
            if (demandes.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: EmptyState.hero(
                  icon: Icons.handshake_outlined,
                  title: isOwner
                      ? 'Aucune demande reçue'
                      : 'Aucun partenariat',
                  body: isOwner
                      ? 'Les demandes des démarcheurs apparaîtront ici.'
                      : 'Envoyez une demande à un propriétaire pour démarrer un partenariat.',
                  ctaLabel: isOwner ? null : 'Nouvelle demande',
                  onCtaTap: isOwner ? null : _onSendDemande,
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
              child: PartenariatsListCard(
                demandes: demandes,
                isOwnerView: isOwner,
                onAccept: isOwner ? _onAccept : null,
                onRefuse: isOwner ? _onRefuse : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
