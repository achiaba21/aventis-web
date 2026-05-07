import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_event.dart';
import 'package:asfar/bloc/appartement_bloc/appartement_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/proprio/home/widget/appartements_section.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/loader/shimmer_card.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// Contenu du tab Listings (appartements du propriétaire)
class ListingsContent extends StatelessWidget {
  final void Function(Appartement) onViewDetails;

  const ListingsContent({
    super.key,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppartementBloc, AppartementState>(
      builder: (context, state) {
        if (state is AppartementInitial || state is AppartementLoading) {
          return const ListShimmer(itemCount: 6);
        }

        if (state is ProprietaireAppartementsLoaded) {
          return AppartementsSection(
            appartements: state.appartements,
            onViewDetails: onViewDetails,
          );
        }

        if (state is AppartementError) {
          return ListingsErrorState(
            message: state.message,
            onRetry: () {
              context.read<AppartementBloc>().add(
                    LoadProprietaireAppartements(),
                  );
            },
          );
        }

        // État par défaut
        return const ListShimmer(itemCount: 6);
      },
    );
  }
}

/// État d'erreur pour les listings
class ListingsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ListingsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          TextSeed(
            "Erreur de chargement",
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 8),
          TextSeed(
            message,
            textAlign: TextAlign.center,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: TextSeed("Réessayer"),
          ),
        ],
      ),
    );
  }
}
