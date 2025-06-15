import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/screen/client/locataire/booking/book_screen.dart';
import 'package:web_flutter/screen/client/locataire/booking/widget/proprio_tile.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/formate.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/plain_button_icon.dart';
import 'package:web_flutter/widget/img/image_app.dart';
import 'package:web_flutter/widget/img/image_net.dart';
import 'package:web_flutter/widget/item/appart/appart_localisation.dart';
import 'package:web_flutter/widget/item/note.dart';
import 'package:web_flutter/widget/text/text_badge.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

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
  late AppData app;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reservation = widget.reservation;
    appartement = reservation.appart;
    plage = reservation.plage;
    app = Provider.of<AppData>(context, listen: false);
  }

  void findAppart() {}

  void onSelect() {
    app.setSelectedReservation(reservation);
    relativePush(context, BookScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = 150.0;
    return InkWell(
      onTap: onSelect,
      child: Container(
        height: size,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Style.containerColor2.withAlpha(100),
          borderRadius: BorderRadius.circular(Espacement.radius),
        ),
        child: Row(
          spacing: Espacement.gapItem,
          children: [
            Expanded(
              child: ImageNet(
                appartement?.imgUrl,
                height: size,
                radius: Espacement.radius,
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Gap(4),info
                    Row(
                      children: [
                        Expanded(child: TextSeed(appartement?.titre)),
                        TextBadge(text: "Payé"),
                      ],
                    ),
                    AppartLocalisation(
                      address: appartement?.residence?.address,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: Espacement.gapSection,
                      children: [
                        Expanded(child: TextSeed(formateRangeTimeShort(plage))),
                        Note(appartement?.note),
                      ],
                    ),
                    Gap(Espacement.gapSection),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      children: [
                        ProprioTile(proprio: reservation.proprio),
                        PlainButtonIcon(
                          value: "message hote",
                          image: Icons.message,
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
