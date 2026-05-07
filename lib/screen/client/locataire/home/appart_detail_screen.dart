import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_state.dart';
import 'package:asfar/bloc/user_bloc/user_bloc.dart';
import 'package:asfar/bloc/user_bloc/user_state.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/request/reservation_req.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/home/reservation.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_bottom.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_offer.dart';
import 'package:asfar/screen/client/locataire/home/widget/appart_review.dart';
import 'package:asfar/screen/client/locataire/home/widget/house_rule.dart';
import 'package:asfar/screen/client/locataire/home/widget/sejour_selector.dart';
import 'package:asfar/screen/login/login_screen.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/icon_boutton.dart';
import 'package:asfar/widget/item/appart/appart_proprio_info.dart';
import 'package:asfar/widget/img/image_carousel.dart';
import 'package:asfar/widget/item/appart/appart_titre_info.dart';
import 'package:asfar/widget/item/appart/remise_info.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AppartDetailScreen extends StatelessWidget {
  const AppartDetailScreen(this.appartement, {super.key});
  final Appartement appartement;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppartBottom(
        appartement: appartement,
        onPress: () {
          if (_requiresAuthentication(context)) {
            pushScreen(context, Reservation());
          }
        },
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  _AppartImageHeader(
                    appartement: appartement,
                    onBack: () => back(context),
                    onFavoriteToggle: () {
                      if (_requiresAuthentication(context)) {
                        context.read<FavoriteBloc>().add(
                          ToggleFavorite(appartement.id!),
                        );
                      }
                    },
                    requiresAuth: () => _requiresAuthentication(context),
                  ),
                  _AppartDetailContent(
                    appartement: appartement,
                    requiresAuth: () => _requiresAuthentication(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Vérifie si l'utilisateur est connecté, sinon redirige vers la connexion
  bool _requiresAuthentication(BuildContext context) {
    final userState = context.read<UserBloc>().state;
    final isGuest = userState is! UserLoaded;

    if (isGuest) {
      _showLoginPrompt(context);
      return false;
    }
    return true;
  }

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.background,
            title: TextSeed(
              "Connexion requise",
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            content: TextSeed(
              "Vous devez vous connecter pour accéder à cette fonctionnalité.",
            ),
            actions: [
              TextButton(
                onPressed: () => back(context),
                child: TextSeed("Annuler", color: AppColors.textMuted),
              ),
              ElevatedButton(
                onPressed: () {
                  back(context); // Fermer le dialogue
                  pushScreen(context, LoginScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
                child: TextSeed("Se connecter", color: AppColors.textOnAccent),
              ),
            ],
          ),
    );
  }
}

/// En-tête avec image et boutons retour/favori
class _AppartImageHeader extends StatelessWidget {
  final Appartement appartement;
  final VoidCallback onBack;
  final VoidCallback onFavoriteToggle;
  final bool Function() requiresAuth;

  const _AppartImageHeader({
    required this.appartement,
    required this.onBack,
    required this.onFavoriteToggle,
    required this.requiresAuth,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ImageCarousel(
          photos: appartement.photos,
          fallbackUrl: appartement.imgUrl,
          height: 300,
        ),
        Padding(
          padding: EdgeInsets.all(Espacement.paddingBloc),
          child: Row(
            children: [
              IconBoutton(
                onPressed: onBack,
                icon: Icons.arrow_back,
                size: 18,
                bgColor: AppColors.background,
              ),
              const Spacer(),
              BlocBuilder<FavoriteBloc, FavoriteState>(
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
                    onPressed:
                        isLoading
                            ? null
                            : () {
                              if (requiresAuth()) {
                                context.read<FavoriteBloc>().add(
                                  ToggleFavorite(appartement.id!),
                                );
                              }
                            },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Contenu détaillé de l'appartement
class _AppartDetailContent extends StatelessWidget {
  final Appartement appartement;
  final bool Function() requiresAuth;

  const _AppartDetailContent({
    required this.appartement,
    required this.requiresAuth,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReservationBloc, ReservationState>(
      builder: (context, reservationState) {
        final req = reservationState.currentReq;

        final reservationBloc = context.read<ReservationBloc>();

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppartTitreInfo(appartement),
              const Divider(),
              AppartProprioInfo(appartement),

              TextSeed(
                appartement.description?.isNotEmpty == true
                    ? appartement.description!
                    : "Aucune description disponible pour cet appartement.",
                textAlign: TextAlign.justify,
              ),
              const Divider(),
              RemiseInfo(
                remises: appartement.remises,
                prixBase: appartement.prix?.toDouble() ?? 0.0,
              ),
              const Divider(),
              AppartOffer(appartement: appartement),
              const Divider(),
              AppartReview(appartement),
              const Divider(),
              SejourSelector(
                selectedRange: req?.plage,
                appartementId: appartement.id,
                onSelectRange: (plage) {
                  if (!requiresAuth()) return;

                  if (req == null) {
                    final newReq = ReservationReq();
                    newReq.appartement = appartement;
                    newReq.plage = plage;
                    newReq.cur = 'F CFA';
                    reservationBloc.add(SetReservationReq(newReq));
                  } else {
                    req.plage = plage;
                    reservationBloc.add(SetReservationReq(req));
                  }
                },
              ),
              const Divider(),
              HouseRule(rules: appartement.rules),
              Gap(Espacement.gapSection * 5),
            ],
          ),
        );
      },
    );
  }
}
