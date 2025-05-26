import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/screen/client/locataire/home/appart_detail_screen.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/item/start_progress.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartItem extends StatefulWidget {
  const AppartItem(this.appart, {super.key});
  final Appartement appart;

  @override
  State<AppartItem> createState() => _AppartItemState();
}

class _AppartItemState extends State<AppartItem> {
  bool isLike = false;

  @override
  Widget build(BuildContext context) {
    final appart = widget.appart;
    final img = appart.imgUrl;
    final note = appart.note;

    return InkWell(
      onTap: () {
        final req = ReservationReq();
        req.appartement = appart;
        final now = DateTime.now();
        req.plage = DateTimeRange(start: now, end: now.add(Duration(days: 2)));
        AppData app = Provider.of<AppData>(context, listen: false);
        app.setReservationReq(req);
        relativePush(context, "${AppartDetailScreen.routeName}/${appart.id}");
      },
      child: Container(
        child: Column(
          children: [
            if (img != null)
              Image.asset(
                img,
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
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
                  TextSeed(
                    "(${(widget.appart.likes ?? 0) + (isLike ? 1 : 0)})",
                  ),
                  IconBoutton(
                    icon: Icons.favorite,
                    color: isLike ? Colors.red : Style.innactiveColor,
                    onPressed:
                        () => setState(() {
                          deboger("object");
                          isLike = !isLike;
                        }),
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
