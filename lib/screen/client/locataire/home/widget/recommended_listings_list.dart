import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/card/appartement_preview_card.dart';

/// Liste verticale "Recommandés pour vous" du `LocataireHomeScreen` —
/// `AppartementPreviewCard` avec `BlocBuilder` sur `FavoriteBloc` pour
/// le heart.
class RecommendedListingsList extends StatelessWidget {
  final List<Appartement> appartements;
  final void Function(Appartement appartement)? onTap;
  final void Function(Appartement appartement)? onLikeTap;

  const RecommendedListingsList({
    super.key,
    required this.appartements,
    this.onTap,
    this.onLikeTap,
  });

  static List<int> _favoriteIdsFromState(FavoriteState state) {
    if (state is FavoriteLoaded) return state.favoriteIds;
    if (state is FavoriteOptimisticUpdate) return state.favoriteIds;
    if (state is FavoriteActionSuccess) return state.favoriteIds;
    if (state is FavoriteError) return state.favoriteIds ?? const [];
    return const [];
  }

  static bool _isLiked(List<int> ids, Appartement appart) {
    final id = appart.id;
    return id != null && ids.contains(id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, favState) {
        final favIds = _favoriteIdsFromState(favState);
        return Column(
          children: [
            for (var i = 0; i < appartements.length; i++) ...[
              AppartementPreviewCard(
                appartement: appartements[i],
                liked: _isLiked(favIds, appartements[i]),
                onTap: onTap == null ? null : () => onTap!(appartements[i]),
                onLikeTap: onLikeTap == null
                    ? null
                    : () => onLikeTap!(appartements[i]),
              ),
              if (i != appartements.length - 1) const SizedBox(height: 14),
            ],
          ],
        );
      },
    );
  }
}
