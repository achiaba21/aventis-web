import 'package:flutter/material.dart';
import 'package:web_flutter/screen/client/locataire/booking/booking.dart';
import 'package:web_flutter/screen/client/locataire/booking/widget/booking_item.dart';
import 'package:web_flutter/util/dummy.dart';
import 'package:web_flutter/widget/text/text_seed.dart';

class History extends StatelessWidget {
  static String routeName = "history";
  static String get route => "${Booking.routeName}/$routeName";

  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: TextSeed("History")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(children: [...reservations.map((e) => BookingItem(e))]),
        ),
      ),
    );
  }
}
