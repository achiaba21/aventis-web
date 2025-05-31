import 'package:flutter/widgets.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/model/user/client.dart';

class AppData extends ChangeNotifier {
  Client? client;
  ReservationReq? req;
  String get curency => "FCFA";
  Reservation? selectedReservation;

  void setReservationReq(ReservationReq? reqs) {
    reqs?.cur ??= curency;
    req = reqs;

    notifyListeners();
  }

  void setClient(Client client) {
    this.client = client;
    notifyListeners();
  }

  void setSelectedReservation(Reservation? reservation) {
    selectedReservation = reservation;
    notifyListeners();
  }
}
