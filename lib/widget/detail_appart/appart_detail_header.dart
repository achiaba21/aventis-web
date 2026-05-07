import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/img/image_carousel.dart';
import 'package:asfar/theme/app_colors.dart';

/// Header réutilisable avec carousel d'images et boutons (retour + favori + calendrier)
class AppartDetailHeader extends StatelessWidget {
  const AppartDetailHeader({
    super.key,
    required this.appartement,
    this.showFavoriteButton = true,
    this.showCalendarButton = false,
    this.onBack,
    this.onCalendarPressed,
  });

  final Appartement appartement;
  final bool showFavoriteButton;
  final bool showCalendarButton; // Pour les propriétaires
  final VoidCallback? onBack;
  final VoidCallback? onCalendarPressed; // Callback pour ouvrir le calendrier d'occupation

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carousel d'images
        ImageCarousel(
          photos: appartement.photos,
          fallbackUrl: appartement.imgUrl,
          height: 300,
        ),

        // Boutons superposés
        Padding(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Row(
            children: [
              // Bouton retour
              IconBoutton(
                onPressed: onBack ?? () => Navigator.of(context).pop(),
                icon: Icons.arrow_back,
                size: 18,
                bgColor: AppColors.background,
              ),
              Spacer(),

              // Bouton calendrier (optionnel - propriétaires)
              if (showCalendarButton) ...[
                IconBoutton(
                  onPressed: onCalendarPressed,
                  icon: Icons.calendar_month,
                  size: 18,
                  bgColor: AppColors.background,
                ),
                SizedBox(width: Espacement.gapItem),
              ],

              // Bouton favori (optionnel)
              if (showFavoriteButton) _buildFavoriteButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return BlocBuilder<FavoriteBloc, FavoriteState>(
      builder: (context, state) {
        bool isLike = false;
        bool isLoading = false;

        if (state is FavoriteLoaded) {
          isLike = state.isFavorite(appartement.id!);
        } else if (state is FavoriteOptimisticUpdate) {
          isLike = state.isFavorite(appartement.id!);
          isLoading = state.pendingApartId == appartement.id;
        } else if (state is FavoriteActionSuccess) {
          isLike = state.isFavorite(appartement.id!);
        } else if (state is FavoriteError) {
          isLike = state.isFavorite(appartement.id!);
        }

        return IconBoutton(
          icon: Icons.favorite,
          size: 18,
          color: isLike ? AppColors.error : null,
          onPressed: isLoading
              ? null
              : () {
                  context.read<FavoriteBloc>().add(ToggleFavorite(appartement.id!));
                },
        );
      },
    );
  }
}
