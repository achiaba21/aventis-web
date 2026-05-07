import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_event.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/demarcheur/partenariat/widget/demande_envoyee_item.dart';
import 'package:asfar/screen/client/demarcheur/partenariat/widget/envoyer_demande_form.dart';
import 'package:asfar/screen/client/demarcheur/profile/demarcheur_profile_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/text/text_seed.dart';

class DemarcheurPartenariatScreen extends StatefulWidget {
  const DemarcheurPartenariatScreen({super.key});

  @override
  State<DemarcheurPartenariatScreen> createState() =>
      _DemarcheurPartenariatScreenState();
}

class _DemarcheurPartenariatScreenState
    extends State<DemarcheurPartenariatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PartenariatBloc>().add(const LoadDemandesEnvoyees());
  }

  void _onSend(String telephone) {
    context.read<PartenariatBloc>().add(EnvoyerDemande(telephone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TextSeed(
          'Partenariats',
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            onPressed: () => context
                .read<PartenariatBloc>()
                .add(const LoadDemandesEnvoyees()),
            icon: const Icon(Icons.refresh),
            color: AppColors.accent,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            onPressed: () => pushScreen(context, const DemarcheurProfileScreen()),
            icon: const Icon(Icons.person_outline),
            color: AppColors.accent,
            tooltip: 'Profil',
          ),
        ],
      ),
      body: BlocConsumer<PartenariatBloc, PartenariatState>(
        listener: (context, state) {
          if (state is DemandeEnvoyeeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Demande envoyée avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is PartenariatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is PartenariatLoading;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                child: EnvoyerDemandeForm(
                  isLoading: isLoading,
                  onSend: _onSend,
                ),
              ),
              Expanded(child: _buildList(context, state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, PartenariatState state) {
    if (state is PartenariatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PartenariatError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              TextSeed(
                state.message,
                color: AppColors.textMuted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context
                    .read<PartenariatBloc>()
                    .add(const LoadDemandesEnvoyees()),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is DemandesEnvoyeesLoaded) {
      if (state.demandes.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.handshake_outlined,
                  size: 64,
                  color: AppColors.inactive,
                ),
                const SizedBox(height: 16),
                TextSeed(
                  'Aucune demande envoyée',
                  fontSize: 16,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextSeed(
                  'Saisissez le numéro d\'un propriétaire pour lui envoyer une demande.',
                  fontSize: 13,
                  color: AppColors.textMuted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.symmetric(
          horizontal: Espacement.paddingBloc,
          vertical: Espacement.gapSection,
        ),
        itemCount: state.demandes.length,
        separatorBuilder: (_, __) =>
            SizedBox(height: Espacement.gapSection),
        itemBuilder: (context, index) =>
            DemandeEnvoyeeItem(demande: state.demandes[index]),
      );
    }

    return const SizedBox.shrink();
  }
}
