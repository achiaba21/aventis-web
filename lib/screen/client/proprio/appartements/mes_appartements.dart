import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/screen/client/proprio/appartements/proprio_appart_detail_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/card/appartement_status_card.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

class MesAppartements extends StatefulWidget {
  const MesAppartements({super.key});

  @override
  State<MesAppartements> createState() => _MesAppartementsState();
}

class _MesAppartementsState extends State<MesAppartements> {
  // Plus besoin de initState() - le préchargement s'en occupe automatiquement

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: TextSeed(
          "Mes Appartements",
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        elevation: 0,
      ),
      body: BlocBuilder<AppartementBloc, AppartementState>(
        builder: (context, state) {
          // Afficher skeleton pendant le chargement initial (préchargement en cours)
          if (state is AppartementInitial) {
            return const ListShimmer(itemCount: 5);
          }

          // Afficher skeleton pendant le chargement manuel (cohérence UX)
          if (state is AppartementLoading) {
            return const ListShimmer(itemCount: 5);
          }

          if (state is AppartementError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  SizedBox(height: Espacement.paddingBloc),
                  TextSeed(
                    state.message,
                    fontSize: 16,
                    color: AppColors.textPrimary.withValues(alpha: 0.7),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: Espacement.paddingBloc * 2),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<AppartementBloc>().add(LoadProprietaireAppartements());
                    },
                    icon: Icon(Icons.refresh),
                    label: TextSeed("Réessayer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Gérer aussi AppartementOperationSuccess après opérations CRUD
          if (state is ProprietaireAppartementsLoaded || state is AppartementOperationSuccess) {
            final appartements = state is ProprietaireAppartementsLoaded
                ? state.appartements
                : (state as AppartementOperationSuccess).appartements;

            if (appartements.isEmpty) {
              // ✅ Ajouter RefreshIndicator même quand la liste est vide
              // pour permettre le pull-to-refresh
              final bloc = context.read<AppartementBloc>();
              return RefreshIndicator(
                onRefresh: () async {
                  bloc.add(RefreshProprietaireAppartements());
                  await bloc.stream.firstWhere(
                    (state) => state is ProprietaireAppartementsLoaded || state is AppartementError,
                    orElse: () => bloc.state,
                  ).timeout(
                    const Duration(seconds: 5),
                    onTimeout: () => bloc.state,
                  );
                },
                color: AppColors.accent,
                // CustomScrollView pour permettre le scroll même quand c'est vide
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.apartment,
                              size: 80,
                              color: AppColors.textPrimary.withValues(alpha: 0.3),
                            ),
                            SizedBox(height: Espacement.paddingBloc),
                            TextSeed(
                              "Aucun appartement",
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            SizedBox(height: Espacement.gapSection),
                            TextSeed(
                              "Vous n'avez pas encore créé d'appartement",
                              fontSize: 14,
                              color: AppColors.textPrimary.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                // ✅ PRINCIPE SOLID - Single Responsibility (S) :
                // Utiliser RefreshProprietaireAppartements qui force le rechargement depuis l'API
                // Au lieu de LoadProprietaireAppartements qui utilise le cache
                final bloc = context.read<AppartementBloc>();
                bloc.add(RefreshProprietaireAppartements());

                // Attendre que le BLoC émette le nouvel état
                await bloc.stream.firstWhere(
                  (state) => state is ProprietaireAppartementsLoaded || state is AppartementError,
                  orElse: () => bloc.state,
                ).timeout(
                  const Duration(seconds: 5),
                  onTimeout: () => bloc.state,
                );
              },
              color: AppColors.accent,
              child: ListView.builder(
                padding: EdgeInsets.all(Espacement.paddingBloc),
                itemCount: appartements.length,
                itemBuilder: (context, index) {
                  final appartement = appartements[index];
                  return AppartementStatusCard(
                    appartement: appartement,
                    onViewDetails: () {
                      pushScreen(context, ProprioAppartDetailScreen(appartement));
                    },
                  );
                },
              ),
            );
          }

          return Center(
            child: TextSeed(
              "Chargement...",
              color: AppColors.textPrimary.withValues(alpha: 0.7),
            ),
          );
        },
      ),
    );
  }
}