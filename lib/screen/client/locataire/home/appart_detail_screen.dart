import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_bloc.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_event.dart';
import 'package:web_flutter/bloc/appartement_bloc/appartement_state.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_event.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_state.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/screen/client/locataire/home/reservation.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_bottom.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_offer.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_review.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/house_rule.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/info_cancel.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/sejour_selector.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/button/plain_button.dart';
import 'package:web_flutter/widget/item/appart/appart_proprio_info.dart';
import 'package:web_flutter/widget/img/image_carousel.dart';
import 'package:web_flutter/widget/item/appart/appart_titre_info.dart';
import 'package:web_flutter/widget/item/appart/remise_info.dart';
import 'package:web_flutter/widget/loader/circular_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartDetailScreen extends StatelessWidget {
  static final routeName = "details";
  const AppartDetailScreen(this.appartId, {super.key});
  final int appartId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppartementBloc, AppartementState>(
      builder: (context, state) {
        if (state is AppartementLoading || state is AppartementInitial) {
          return Scaffold(
            backgroundColor: Style.containerColor3,
            body: Center(child: CircularProgress()),
          );
        } else if (state is AppartementError) {
          return Scaffold(
            backgroundColor: Style.containerColor3,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
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
                      onPress: () => context.read<AppartementBloc>().add(LoadAppartements()),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else if (state is AppartementLoaded) {
          final appart = findByid(state.appartements, ((element) => element.id == appartId));
          if (appart == null) {
            return Scaffold(
              backgroundColor: Style.containerColor3,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_outlined, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 24),
                    TextSeed(
                      "Appartement introuvable",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: 8),
                    TextSeed(
                      "Cet appartement n'existe plus ou a été supprimé",
                      textAlign: TextAlign.center,
                      color: Colors.grey[600],
                    ),
                    SizedBox(height: 32),
                    PlainButton(
                      value: "Retour à la liste",
                      onPress: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildAppartementDetail(context, appart);
        }

        return Scaffold(
          backgroundColor: Style.containerColor3,
          body: Center(child: CircularProgress()),
        );
      },
    );
  }

  Widget _buildAppartementDetail(BuildContext context, Appartement appart) {
    AppData app = Provider.of<AppData>(context);
    final req = app.req;

     

    return Scaffold(
      backgroundColor: Style.containerColor3,
      bottomNavigationBar:  AppartBottom(
              appartement: appart,
              
              onPress: () => relativePush(context, Reservation.routeName),
            ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ImageCarousel(
                        photos: appart.photos,
                        fallbackUrl: appart.imgUrl,
                        height: 300,
                      ),
                      Padding(
                        padding: EdgeInsets.all(Espacement.paddingBloc),
                        child: Row(
                          children: [
                            IconBoutton(
                              onPressed: () => back(context),
                              icon: Icons.arrow_back,
                              size: 18,
                              bgColor: Style.containerColor2,
                            ),
                            Spacer(),
                            BlocBuilder<FavoriteBloc, FavoriteState>(
                              builder: (context, state) {
                                bool isLike = false;
                                bool isLoading = false;

                                if (state is FavoriteLoaded) {
                                  isLike = state.isFavorite(appart.id!);
                                } else if (state is FavoriteOptimisticUpdate) {
                                  isLike = state.isFavorite(appart.id!);
                                  isLoading = state.pendingApartId == appart.id;
                                } else if (state is FavoriteActionSuccess) {
                                  isLike = state.isFavorite(appart.id!);
                                } else if (state is FavoriteError) {
                                  isLike = state.isFavorite(appart.id!);
                                }

                                return IconBoutton(
                                  icon: Icons.favorite,
                                  size: 18,
                                  color: isLike ? Colors.red : null,
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          context.read<FavoriteBloc>().add(ToggleFavorite(appart.id!));
                                        },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppartTitreInfo(appart),
                        Divider(),
                        AppartProprioInfo(appart),
                        Divider(),
                        InfoCancel(),
                        Divider(),
                        TextSeed(
                          appart.description?.isNotEmpty == true
                              ? appart.description!
                              : "Aucune description disponible pour cet appartement.",
                          textAlign: TextAlign.justify,
                        ),
                        Divider(),
                        RemiseInfo(
                          remises: appart.remises,
                          prixBase: appart.prix?.toDouble() ?? 0.0,
                        ),
                        Divider(),
                        AppartOffer(appartement: appart),
                        Divider(),
                        AppartReview(appart),
                        Divider(),
                        SejourSelector(
                          selectedRange: req?.plage,
                          onSelectRange: (p0) {
                            // Créer une nouvelle ReservationReq si elle n'existe pas
                            if (req == null) {
                              final newReq = ReservationReq();
                              newReq.appartement = appart;
                              newReq.plage = p0;
                              app.setReservationReq(newReq);
                            } else {
                              req.plage = p0;
                              app.setReservationReq(req);
                            }
                          },
                        ),
                        Divider(),
                        HouseRule(),
                        Gap(Espacement.gapSection * 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
           
          ],
        ),
      ),
    );
  }
}
