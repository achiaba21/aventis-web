import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/plain_button_expand.dart';
import 'package:web_flutter/widget/img/image_app.dart';
import 'package:web_flutter/widget/input/input_field.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class PayementAddPage extends StatelessWidget {
  static String routeName = "payement-page";
  const PayementAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TextSeed("Paiement")),
      body: Padding(
        padding: EdgeInsets.all(Espacement.gapSection),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(Espacement.gapSection * 2),
            ImageApp("assets/image/bank/visa.png", width: 100, height: 16),
            Gap(Espacement.gapItem * 3),
            InputField(
              placeHolder: "Cart number",
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    placeHolder: "Expiration",
                    keyboardType: TextInputType.number,
                  ),
                ),
                Expanded(
                  child: InputField(
                    placeHolder: "cvv",
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            Gap(Espacement.gapItem * 3),
            InputField(placeHolder: "Adresse"),

            Spacer(),
            PlainButtonExpand(
              value: "Enregistrer",
              onPress: () => back(context),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
