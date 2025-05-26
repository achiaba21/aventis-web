import 'package:web_flutter/model/residence/appart.dart';
import 'package:web_flutter/model/residence/commodite/commodite.dart';

class Offre {
  int? id;
  Commodite? commodite;
  Appartement? appartement;

  Offre({this.id, this.commodite, this.appartement});

  Offre.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    commodite =
        json['commodite'] != null
            ? Commodite.fromJsonAll(json['commodite'])
            : null;
    appartement =
        json['appartement'] != null
            ? Appartement.fromJson(json['appartement'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (commodite != null) {
      data['commodite'] = commodite!.toJson();
    }
    if (appartement != null) {
      data['appartement'] = appartement!.toJson();
    }
    return data;
  }
}
