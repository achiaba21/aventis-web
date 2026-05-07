import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/widget/button/plain_button.dart';
import 'package:asfar/widget/text/text_seed.dart';

/// État vide des favoris
class FavoriteEmptyState extends StatelessWidget {
  final VoidCallback? onExplore;

  const FavoriteEmptyState({
    super.key,
    this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 24),
            TextSeed(
              "Aucun favori",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            TextSeed(
              "Explorez nos appartements et ajoutez-les à vos favoris",
              textAlign: TextAlign.center,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 32),
            PlainButton(
              value: "Explorer",
              onPress: onExplore ?? () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// État d'erreur des favoris
class FavoriteErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const FavoriteErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 24),
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
            const SizedBox(height: 32),
            PlainButton(
              value: "Réessayer",
              onPress: onRetry ?? () => context.read<FavoriteBloc>().add(LoadFavorites()),
            ),
          ],
        ),
      ),
    );
  }
}
