
import 'package:flutter/material.dart';
import 'package:web_flutter/model/message/seance.dart';
import 'package:web_flutter/model/notification.dart';
import 'package:web_flutter/model/request/reservation_req.dart';
import 'package:web_flutter/model/reservation/reservation.dart';
import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/model/user/client.dart';

class AppData extends ChangeNotifier {
  Client? client;
  ReservationReq? req;
  String get curency => "FCFA";
  Reservation? selectedReservation;
  List<int> favorites = [];
  List<Notification2> notifs =[];
  List<Seance> seance =[];

  void toggleFavorites(Appartement appart){
    final id =appart.id;
    if( id == null){
      return;
    }
    final inner = favorites.contains(id);
    if(inner){
      favorites.remove(id);
    }else{
      favorites.add(id);
    }
    notifyListeners();
  }

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
