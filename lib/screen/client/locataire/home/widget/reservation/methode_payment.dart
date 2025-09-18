import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_flutter/model/enumeration/moyen_paiement.dart';
import 'package:web_flutter/service/providers/app_data.dart';
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
  MoyenPaiement? selectedPayment;

  @override
  Widget build(BuildContext context) {
    final appData = Provider.of<AppData>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextSeed("Choisissez votre moyen de paiement", fontSize: 16, fontWeight: FontWeight.w600),
        SizedBox(height: 12),

        // Orange Money
        CustomTile(
          leftSvgPath: "assets/icon/mobile_monney.svg",
          libelle: "Orange Money",
          rightImage: selectedPayment == MoyenPaiement.OM
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          onPressed: () => _selectPaymentMethod(MoyenPaiement.OM, appData),
        ),

        // Moov Money
        CustomTile(
          leftSvgPath: "assets/icon/mobile_monney.svg",
          libelle: "Moov Money",
          rightImage: selectedPayment == MoyenPaiement.MOOV_MONNEY
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          onPressed: () => _selectPaymentMethod(MoyenPaiement.MOOV_MONNEY, appData),
        ),

        // MTN Mobile Money
        CustomTile(
          leftSvgPath: "assets/icon/mobile_monney.svg",
          libelle: "MTN Mobile Money",
          rightImage: selectedPayment == MoyenPaiement.MOMO
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          onPressed: () => _selectPaymentMethod(MoyenPaiement.MOMO, appData),
        ),

        // Wave
        CustomTile(
          leftSvgPath: "assets/icon/mobile_monney.svg",
          libelle: "Wave",
          rightImage: selectedPayment == MoyenPaiement.WAVE
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
          onPressed: () => _selectPaymentMethod(MoyenPaiement.WAVE, appData),
        ),

        // Carte de crédit (optionnel)
        CustomTile(
          leftSvgPath: "assets/icon/debit.svg",
          libelle: "Carte de crédit ou de débit",
          rightImage: Icons.add_box,
          onPressed: () => relativePush(context, PayementAddPage.routeName),
        ),
      ],
    );
  }

  void _selectPaymentMethod(MoyenPaiement payment, AppData appData) {
    setState(() {
      selectedPayment = payment;
    });

    // Sauvegarder dans AppData
    final req = appData.req;
    if (req != null) {
      req.moyenPaiement = payment;
      appData.setReservationReq(req);
    }
  }
}
