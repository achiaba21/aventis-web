import 'package:web_flutter/model/message/message.dart';
import 'package:web_flutter/model/user/client.dart';
import 'package:web_flutter/model/user/locataire.dart';
import 'package:web_flutter/model/user/proprietaire.dart';
import 'package:web_flutter/util/formate.dart';

class Seance {
  Proprietaire? proprietaire;
  Locataire? locataire;
  DateTime? dateDebut;
  DateTime? dateFin;
  bool? active;

  Seance({
    this.proprietaire,
    this.locataire,
    this.dateDebut,
    this.dateFin,
    this.active,
  });

  Client? get contact => proprietaire ?? locataire;

  List<Message> message =[];

  Message get last => message.last; 

  Seance.fromJson(Map<String, dynamic> json) {
    dateDebut = toDate(json['dateDebut']);
    dateFin = toDate(json['dateFin']) ;
    active = json['active'];
    proprietaire = json['proprietaire'] != null ? Proprietaire.fromJson(json['proprietaire']) : null;
    locataire = json['locataire'] != null ? Locataire.fromJson(json['locataire']) : null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dateDebut'] = dateDebut?.toIso8601String();
    data['dateFin'] = dateFin?.toIso8601String();
    data['active'] = active;
    data['proprietaire'] = proprietaire?.toJson();
    data['locataire'] = locataire?.toJson();
    return data;
  }
}
