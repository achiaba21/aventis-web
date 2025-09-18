import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_event.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_state.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_item.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/loader/circular_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Favorite extends StatelessWidget {
  static final String routeName = "/favoris";

  const Favorite({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TextSeed("Favoris")),
      body: BlocListener<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is FavoriteActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        child: BlocBuilder<FavoriteBloc, FavoriteState>(
          builder: (context, state) {
            if (state is FavoriteInitial) {
              context.read<FavoriteBloc>().add(LoadFavoriteAppartements());
              return const Center(child: CircularProgress());
            } else if (state is FavoriteLoading) {
              return const Center(child: CircularProgress());
            } else if (state is FavoriteAppartementsLoaded) {
              if (state.appartements.isEmpty) {
                return _buildEmptyState(context);
              }

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextSeed(
                          "${state.appartements.length} appartement${state.appartements.length > 1 ? 's' : ''} favori${state.appartements.length > 1 ? 's' : ''}",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ...state.appartements.map((appart) => AppartItem(appart)),
                    ],
                  ),
                ),
              );
            } else if (state is FavoriteError) {
              return _buildErrorState(context, state);
            } else if (state is FavoriteLoaded) {
              // Si on a seulement les IDs, recharger les appartements complets
              context.read<FavoriteBloc>().add(LoadFavoriteAppartements());
              return const Center(child: CircularProgress());
            }

            return const Center(child: CircularProgress());
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
            SizedBox(height: 24),
            TextSeed(
              "Aucun favori",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 8),
            TextSeed(
              "Explorez nos appartements et ajoutez-les à vos favoris",
              textAlign: TextAlign.center,
              color: Colors.grey[600],
            ),
            SizedBox(height: 32),
            PlainButton(
              value: "Explorer",
              onPress: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, FavoriteError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 24),
            TextSeed(
              "Erreur de chargement",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 8),
            TextSeed(
              state.message,
              textAlign: TextAlign.center,
              color: Colors.grey[600],
            ),
            SizedBox(height: 32),
            PlainButton(
              value: "Réessayer",
              onPress: () => context.read<FavoriteBloc>().add(LoadFavoriteAppartements()),
            ),
          ],
        ),
      ),
    );
  }
}
