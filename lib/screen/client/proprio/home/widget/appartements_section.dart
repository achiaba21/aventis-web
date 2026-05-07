import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/card/appartement_status_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AppartementsSection extends StatelessWidget {
  const AppartementsSection({
    super.key,
    required this.appartements,
    required this.onViewDetails,
  });

  final List<Appartement> appartements;
  final Function(Appartement) onViewDetails;

  @override
  Widget build(BuildContext context) {
    return appartements.isEmpty
        ? _buildEmptyState()
        : _buildAppartementsList();
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (context) {
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
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      TextSeed(
                        "Aucun appartement",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 8),
                      TextSeed(
                        "Ajoutez votre premier appartement",
                        textAlign: TextAlign.center,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppartementsList() {
    return Builder(
      builder: (context) {
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
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: appartements.length,
            itemBuilder: (context, index) {
              final appartement = appartements[index];
              return AppartementStatusCard(
                appartement: appartement,
                onViewDetails: () => onViewDetails(appartement),
              );
            },
          ),
        );
      },
    );
  }

  
}