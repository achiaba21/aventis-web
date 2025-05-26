import 'dart:math';

import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/model/user/proprietaire.dart';

final apparts = [
  Appartement(
    id: 1,
    description:
        "Unwind at this stunning French Provencal beachside cottage. The house was lovingly built with stone floors, high-beamed ceilings, and antique details for a luxurious yet charming feel. Enjoy the sea and mountain views from the pool and lush garden. The house is located in the enclave of Llandudno Beach, a locals-only spot with unspoilt, fine white sand and curling surfing waves. Although shops and restaurants are only a five-minute drive away, the area feels peaceful and secluded.",
    imgUrl: "assets/image/dummy/fistapp.png",
    numro: "A29",
    prix: 250000,
    titre: "Deluxe Private room with pool",
    likes: Random().nextInt(100),
  ),
  Appartement(
    id: 2,
    description:
        "Unwind at this stunning French Provencal beachside cottage. The house was lovingly built with stone floors, high-beamed ceilings, and antique details for a luxurious yet charming feel. Enjoy the sea and mountain views from the pool and lush garden. The house is located in the enclave of Llandudno Beach, a locals-only spot with unspoilt, fine white sand and curling surfing waves. Although shops and restaurants are only a five-minute drive away, the area feels peaceful and secluded.",
    imgUrl: "assets/image/dummy/img2.png",
    numro: "C45",
    prix: 150000,
    titre: "Deluxe Private room with pool",
    likes: Random().nextInt(100),
  ),
];

final reservations = [
  Reservation(
    appart: apparts[0],
    debut: DateTime.now().subtract(Duration(days: 6)),
    fin: DateTime.now().subtract(Duration(days: 4)),
    prix: apparts[0].prix,
    proprio: Proprietaire(),
  ),
];
final amenities = [
  "Air conditioning",
  "Wifi",
  "Kitchen",
  "TV",
  "Water heater",
  "Gym",
  "Pool",
];
final roomPreferences = ["Entire place", "Shared space", "Private room"];
final rules = ["Pets", "Smoking"];
