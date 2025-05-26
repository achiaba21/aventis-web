import 'package:flutter/material.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/util/payement_add_page.dart';
import 'package:web_flutter/widget/item/custom_tile.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class MethodePayment extends StatefulWidget {
  const MethodePayment({super.key});

  @override
  State<MethodePayment> createState() => _MethodePaymentState();
}

class _MethodePaymentState extends State<MethodePayment> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextSeed("Payer avec"),
        CustomTile(
          leftSvgPath: "assets/icon/debit.svg",
          libelle: "Carte de credit ou de debit",
          rightImage: Icons.add_box,
          onPressed: () => relativePush(context, PayementAddPage.routeName),
        ),
        CustomTile(
          leftSvgPath: "assets/icon/mobile_monney.svg",
          libelle: "Mobile monney",
          rightImage: Icons.add_box,
        ),
      ],
    );
  }
}
