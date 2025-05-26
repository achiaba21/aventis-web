import 'package:flutter/material.dart';
import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/screen/client/locataire/booking/history.dart';
import 'package:web_flutter/screen/client/locataire/booking/widget/booking_item.dart';
import 'package:web_flutter/util/dummy.dart';
import 'package:web_flutter/util/navigation.dart';
import 'package:web_flutter/widget/button/texte_button.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class Booking extends StatelessWidget {
  static final String routeName = "/booking";
  const Booking({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TextSeed("Booking")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            spacing: Espacement.gapSection,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TexteButton(
                    text: "History",
                    onPressed: () => push(context, History.route),
                  ),
                ],
              ),
              ...reservations.map((reservation) => BookingItem(reservation)),
            ],
          ),
        ),
      ),
    );
  }
}
