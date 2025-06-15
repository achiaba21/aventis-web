import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/home/reservation.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_bottom.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_offer.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/appart_review.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/house_rule.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/info_cancel.dart';
import 'package:web_flutter/screen/client/locataire/home/widget/sejour_selector.dart';
import 'package:web_flutter/service/providers/app_data.dart';
import 'package:web_flutter/service/providers/style.dart';
import 'package:web_flutter/util/dummy.dart';
import 'package:web_flutter/util/function.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/icon_boutton.dart';
import 'package:web_flutter/widget/item/appart/appart_proprio_info.dart';
import 'package:web_flutter/widget/item/appart/appart_titre_info.dart';
import 'package:web_flutter/widget/item/circle_icon.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class AppartDetailScreen extends StatelessWidget {
  static final routeName = "details";
  const AppartDetailScreen(this.appartId, {super.key});
  final int appartId;

  @override
  Widget build(BuildContext context) {
    AppData app = Provider.of<AppData>(context);

    DateTimeRange? selectedRange;
    final appart = findByid(apparts, ((element) => element.id == appartId));
    if (appart == null) {
      return Scaffold(
        body: Center(
          child: TextSeed("Pas d'element trouvé", color: Style.primaryColor),
        ),
      );
    }
    final like = app.favorites.contains(appart.id);
    final comments = appart.commentaires?.firstOrNull;
    final req = app.req;

    return Scaffold(
      backgroundColor: Style.containerColor3,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        appart.imgUrl ?? "",

                        width: double.infinity,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.contain,
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
                            IconBoutton(
                              icon: Icons.favorite,
                              size: 18,
                              color: like ? Colors.red : null,
                              onPressed: () => app.toggleFavorites(appart),
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
                        TextSeed(appart.description),
                        Divider(),
                        AppartOffer(appartement: appart),
                        Divider(),
                        AppartReview(appart),
                        Divider(),
                        SejourSelector(
                          selectedRange: req?.plage,
                          onSelectRange: (p0) {
                            selectedRange = p0;
                            req?.plage = selectedRange;
                            app.setReservationReq(req);
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
            AppartBottom(
              onPress: () => relativePush(context, Reservation.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
