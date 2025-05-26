import 'package:web_flutter/model/reservation/commentaire/commentaire.dart';
import 'package:web_flutter/model/reservation/reservation.dart';

class CommentaireReservation extends Commentaire {
  Reservation? reservation;

  CommentaireReservation({
    int? id,
    int? note,
    String? contenu,

    this.reservation,
  }) : super(id: id, note: note, contenu: contenu);

  CommentaireReservation.fromJson(Map<String, dynamic> json)
    : super.fromJson(json) {
    reservation =
        json['reservation'] != null
            ? Reservation.fromJson(json['reservation'])
            : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();

    if (reservation != null) {
      data['reservation'] = reservation!.toJson();
    }
    return data;
  }
}
