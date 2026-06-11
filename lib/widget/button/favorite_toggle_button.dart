import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/widget/img/floating_heart_button.dart';

/// Cœur favori autonome d'une carte d'annonce (PERF-03)
///
/// `BlocSelector` sur `state.isFavorite(id)` : seul CE bouton se reconstruit
/// quand le statut favori de SON annonce change — un like ne rebuild plus
/// la liste entière. Visuel inchangé ([FloatingHeartButton]).
class FavoriteToggleButton extends StatelessWidget {
  final int? appartementId;
  final double size;

  const FavoriteToggleButton({
    super.key,
    required this.appartementId,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    final id = appartementId;
    if (id == null) {
      return FloatingHeartButton(onTap: null, active: false, size: size);
    }
    return BlocSelector<FavoriteBloc, FavoriteState, bool>(
      selector: (state) => state.isFavorite(id),
      builder: (context, isFavorite) => FloatingHeartButton(
        active: isFavorite,
        size: size,
        onTap: () => context.read<FavoriteBloc>().add(ToggleFavorite(id)),
      ),
    );
  }
}
