import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_bloc.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_event.dart';
import 'package:asfar/bloc/partenariat_bloc/partenariat_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/proprio/partenariat/widget/demande_recue_item.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/text/text_seed.dart';

class ProprioPartenariatScreen extends StatefulWidget {
  const ProprioPartenariatScreen({super.key});

  @override
  State<ProprioPartenariatScreen> createState() =>
      _ProprioPartenariatScreenState();
}

class _ProprioPartenariatScreenState extends State<ProprioPartenariatScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PartenariatBloc>().add(const LoadDemandesRecues());
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
                .add(const LoadDemandesRecues()),
            icon: const Icon(Icons.refresh),
            color: AppColors.accent,
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: BlocConsumer<PartenariatBloc, PartenariatState>(
        listener: (context, state) {
          if (state is DemandeTraiteeSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Demande traitée avec succès'),
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
                          .add(const LoadDemandesRecues()),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DemandesRecuesLoaded) {
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
                        'Aucune demande reçue',
                        fontSize: 16,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextSeed(
                        'Les demandes de partenariat des démarcheurs apparaîtront ici.',
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
              padding: EdgeInsets.all(Espacement.paddingBloc),
              itemCount: state.demandes.length,
              separatorBuilder: (_, __) =>
                  SizedBox(height: Espacement.gapSection),
              itemBuilder: (context, index) {
                final demande = state.demandes[index];
                return DemandeRecueItem(
                  demande: demande,
                  onAccepter: () => context
                      .read<PartenariatBloc>()
                      .add(AccepterDemande(demande.id)),
                  onRefuser: () => context
                      .read<PartenariatBloc>()
                      .add(RefuserDemande(demande.id)),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
