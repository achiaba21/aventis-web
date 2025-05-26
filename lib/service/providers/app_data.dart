import 'package:flutter/widgets.dart';
import 'package:web_flutter/model/request/reservation_req.dart';

class AppData extends ChangeNotifier {
  ReservationReq? req;
  String get curency => "FCFA";

  void setReservationReq(ReservationReq? reqs) {
    reqs?.cur ??= curency;
    req = reqs;

    notifyListeners();
  }
}
