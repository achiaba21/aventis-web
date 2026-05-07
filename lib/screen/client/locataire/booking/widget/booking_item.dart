import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_bloc.dart';
import 'package:asfar/bloc/conversation_bloc/conversation_event.dart';
import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/reservation/reservation.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/screen/client/locataire/booking/book_screen.dart';
import 'package:asfar/screen/client/locataire/booking/widget/proprio_tile.dart';
import 'package:asfar/theme/app_colors.dart';
import 'package:asfar/util/formate.dart';
import 'package:asfar/util/navigation.dart';
import 'package:asfar/widget/button/plain_button_icon.dart';
import 'package:asfar/widget/img/image_net.dart';
import 'package:asfar/widget/item/note.dart';
import 'package:asfar/widget/reservation/reservation_status_badge_compact.dart';
import 'package:asfar/widget/text/text_seed.dart';

class BookingItem extends StatefulWidget {
  const BookingItem(this.reservation, {super.key});
  final Reservation reservation;

  @override
  State<BookingItem> createState() => _BookingItemState();
}

class _BookingItemState extends State<BookingItem> {
  late Reservation reservation;
  Appartement? appartement;
  DateTimeRange? plage;

  @override
  void initState() {
    super.initState();
    reservation = widget.reservation;
    appartement = reservation.appart;
    plage = reservation.plage;
  }

  void onSelect() {
    pushScreen(context, BookScreen(reservation));
  }

  void onMessage() {
    if (reservation.proprio?.id != null && reservation.locataire?.id != null) {
      context.read<ConversationBloc>().add(
        CreateConversationFromBooking(
          proprietaireId: reservation.proprio!.id!,
          locataireId: reservation.locataire!.id!,
          reservationReference: reservation.reference,
        ),
      );
    }
  }

  // Helper pour obtenir l'URL de l'image de l'appartement
  String? _getImageUrl() {
    if (appartement?.photos?.isNotEmpty == true) {
      return appartement!.photos!.first.path;
    }
    return appartement?.imgUrl;
  }

  @override
  Widget build(BuildContext context) {
    final size = 150.0;
    final status = reservation.statut ?? ReservationStatus.enAttente;
    final nombreNuits = plage?.duration.inDays ?? 0;
    final prix = reservation.prix;

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(Espacement.radius),
      child: Container(
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(Espacement.radius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image de l'appartement
            Expanded(
              child: ImageNet(
                _getImageUrl(),
                height: size,
                radius: Espacement.radius,
              ),
            ),
            Gap(Espacement.gapItem),

            // Contenu à droite
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(Espacement.paddingInput),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Titre et badge de statut
                    Row(
                      children: [
                        Expanded(
                          child: TextSeed(
                            appartement?.titre ?? 'Appartement',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                          ),
                        ),
                        Gap(Espacement.paddingInput),
                        ReservationStatusBadgeCompact(status: status),
                      ],
                    ),
                    Gap(Espacement.paddingInput),

                    // Dates et note
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              Gap(4),
                              Flexible(
                                child: TextSeed(
                                  formateRangeTimeShort(plage),
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (appartement?.note != null) ...[
                          Gap(Espacement.paddingInput),
                          Note(appartement?.note),
                        ],
                      ],
                    ),
                    Gap(Espacement.paddingInput),

                    // Prix et nombre de nuits
                    if (prix != null && nombreNuits > 0) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.nights_stay,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          Gap(4),
                          TextSeed(
                            "$nombreNuits ${nombreNuits > 1 ? 'nuits' : 'nuit'}",
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          Spacer(),
                          TextSeed(
                            "${helpAmountFormate(prix.toInt(), decim: false)} FCFA",
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                      Gap(Espacement.paddingInput),
                    ],

                    Spacer(),

                    // Propriétaire et bouton message (visible uniquement après paiement)
                    Row(
                      children: [
                        Expanded(
                          child: ProprioTile(proprio: reservation.proprio),
                        ),
                        Gap(Espacement.paddingInput),
                        // Bouton message visible uniquement après paiement
                        if (status == ReservationStatus.payee ||
                            status == ReservationStatus.finalisee)
                          PlainButtonIcon(
                            value: "Message",
                            image: Icons.message,
                            onPress: onMessage,
                          )
                        else
                          // Indicateur que le contact sera disponible après paiement
                          Tooltip(
                            message: "Disponible après paiement",
                            child: Icon(
                              Icons.message_outlined,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
