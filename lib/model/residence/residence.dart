import 'package:web_flutter/model/locolite/address.dart';
import 'package:web_flutter/model/user/proprietaire.dart';

class Residence {
  int? id;
  String? nom;
  Address? address;
  Proprietaire? proprietaire;
  String? reference;

  Residence({this.id, this.nom, this.address, this.proprietaire, this.reference});

  Residence.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    proprietaire =
        json['proprietaire'] != null
            ? Proprietaire.fromJson(json['proprietaire'])
            : null;
    reference = json['reference'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['nom'] = nom;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (proprietaire != null) {
      data['proprietaire'] = proprietaire!.toJson();
    }
    data['reference'] = reference;
    return data;
  }
}
