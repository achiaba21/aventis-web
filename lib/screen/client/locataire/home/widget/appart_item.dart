import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_event.dart';
import 'package:web_flutter/bloc/favorite_bloc/favorite_state.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/router/router_manage.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/item/start_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartItem extends StatefulWidget {
  const AppartItem(this.appart, {super.key});
  final Appartement appart;

  @override
  State<AppartItem> createState() => _AppartItemState();
}

class _AppartItemState extends State<AppartItem> {


  
  late AppData app ;
  @override
  void initState() {
    super.initState();
    app = Provider.of<AppData>(context, listen: false);
  }


  @override
  Widget build(BuildContext context) {
    final appart = widget.appart;
    // Récupérer la première image de la liste photos, sinon fallback sur imgUrl
    String? imagePath = appart.photos?.isNotEmpty == true
        ? appart.photos!.first.path
        : appart.imgUrl;

    // Construire l'URL complète avec le domaine si nécessaire
    String? imageUrl;
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        imageUrl = imagePath; // URL complète
      } else if (imagePath.startsWith('assets/')) {
        imageUrl = imagePath; // Asset local
      } else {
        imageUrl = "$domain/$imagePath"; // URL relative, ajouter le domaine
      }
    }

    final note = appart.note;
    
    return InkWell(
      onTap: () {
        final req = ReservationReq();
        req.appartement = appart;
        final now = DateTime.now();
        req.plage = DateTimeRange(start: now, end: now.add(Duration(days: 2)));
        
        app.setReservationReq(req);
        RouterManage.goToAppartDetail(context,appart.id!);
       
      },
      child: Container(
        child: Column(
          children: [
            ImageNet(
              imageUrl,
              height: 250,
              width: double.infinity,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextSeed(widget.appart.titre),
                          Gap(Espacement.gapItem),
                          StartProgress(fillPercentage: note),
                          TextSeed(note.toString()),
                        ],
                      ),
                      TextSeed("${widget.appart.prix} FCFA / nuit"),
                    ],
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

                      return Row(
                        children: [
                          TextSeed(
                            "(${(widget.appart.likes ?? 0) + (isLike ? 1 : 0)})",
                          ),
                          IconBoutton(
                            icon: Icons.favorite,
                            color: isLike ? Colors.red : Style.innactiveColor,
                            onPressed: isLoading
                                ? null
                                : () {
                                    context.read<FavoriteBloc>().add(ToggleFavorite(appart.id!));
                                  },
                          ),
                        ],
                      );
                    },
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
