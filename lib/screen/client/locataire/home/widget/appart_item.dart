import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_event.dart';
import 'package:asfar/bloc/favorite_bloc/favorite_state.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_bloc.dart';
import 'package:asfar/bloc/reservation_bloc/reservation_event.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/request/reservation_req.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/home/appart_detail_screen.dart';
import 'package:asfar/widget/item/appart/appart_localisation.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/text/text_seed.dart';

class AppartItem extends StatefulWidget {
  const AppartItem(this.appart, {super.key});
  final Appartement appart;

  @override
  State<AppartItem> createState() => _AppartItemState();
}

class _AppartItemState extends State<AppartItem> {
  @override
  Widget build(BuildContext context) {
    final appart = widget.appart;
    String? imagePath = appart.photos?.isNotEmpty == true
        ? appart.photos!.first.path
        : appart.imgUrl;

    final note = appart.note ?? 0.0;
    final isNew = appart.createdAt != null &&
        DateTime.now().difference(appart.createdAt!).inDays < 30;

    return Container(
      margin: EdgeInsets.only(bottom: Espacement.paddingBloc),
      child: Card(
        elevation: 2,
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            final req = ReservationReq();
            req.appartement = appart;
            final now = DateTime.now();
            req.plage = DateTimeRange(start: now, end: now.add(Duration(days: 2)));
            req.cur = 'F CFA';

            context.read<ReservationBloc>().add(SetReservationReq(req));
            pushScreen(context, AppartDetailScreen(appart));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec badges et bouton favori
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: ImageNet(
                      imagePath,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),

                  // Badge Nouveau
                  if (isNew)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.info,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextSeed(
                          "Nouveau",
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Bouton favori
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocListener<FavoriteBloc, FavoriteState>(
                      listener: (context, state) {
                        if (state is FavoriteInitial) {
                          context.read<FavoriteBloc>().add(LoadFavorites());
                        }
                      },
                      child: BlocBuilder<FavoriteBloc, FavoriteState>(
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

                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              iconSize: 22,
                              icon: Icon(
                                isLike ? Icons.favorite : Icons.favorite_border,
                                color: isLike ? AppColors.error : AppColors.textSecondary,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      context.read<FavoriteBloc>().add(ToggleFavorite(appart.id!));
                                    },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              // Informations de l'appartement
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre et note
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextSeed(
                            appart.titre ?? "Appartement",
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                          ),
                        ),
                        if (note > 0) ...[
                          Gap(8),
                          Row(
                            children: [
                              Icon(Icons.star, color: AppColors.warning, size: 16),
                              Gap(4),
                              TextSeed(
                                note.toStringAsFixed(1),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    Gap(4),

                    AppartLocalisation(address: appart.address),

                    Gap(8),

                    // Prix
                    Row(
                      children: [
                        TextSeed(
                          "${appart.prix}",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                        Gap(4),
                        TextSeed(
                          "FCFA /nuit",
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),

                    // Caractéristiques (chambres, lits, etc.)
                    if (appart.nbChambres != null || appart.nbLits != null) ...[
                      Gap(6),
                      Row(
                        children: [
                          if (appart.nbChambres != null) ...[
                            Icon(Icons.bed, size: 16, color: AppColors.textSecondary),
                            Gap(4),
                            TextSeed(
                              "${appart.nbChambres} ${appart.nbChambres! > 1 ? 'chambres' : 'chambre'}",
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                          if (appart.nbChambres != null && appart.nbLits != null) ...[
                            Gap(8),
                            TextSeed("•", fontSize: 12, color: AppColors.textMuted),
                            Gap(8),
                          ],
                          if (appart.nbLits != null) ...[
                            Icon(Icons.single_bed, size: 16, color: AppColors.textSecondary),
                            Gap(4),
                            TextSeed(
                              "${appart.nbLits} ${appart.nbLits! > 1 ? 'lits' : 'lit'}",
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
