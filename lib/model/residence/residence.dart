import 'package:web_flutter/model/locolite/address.dart';
import 'package:web_flutter/model/user/proprietaire.dart';

class Residence {
  int? id;
  String? nom;
  Address? address;
  Proprietaire? proprietaire;

  Residence({this.id, this.nom, this.address, this.proprietaire});

  Residence.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    proprietaire =
        json['proprietaire'] != null
            ? Proprietaire.fromJson(json['address'])
            : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['nom'] = nom;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['proprietaire'] = proprietaire;
    return data;
  }
}
