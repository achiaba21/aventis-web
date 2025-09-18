import 'package:web_flutter/model/locolite/lieux/commune.dart';

class Address {
  int? id;
  double? lat;
  double? longi;
  String? nom;
  Commune? commune;
  String? description;

  Address({
    this.id,
    this.lat,
    this.longi,
    this.nom,
    this.commune,
    this.description,
  });

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat'];
    longi = json['longi'];
    nom = json['nom'];
    commune = json['commune'] != null ? Commune.fromJson(json['commune']) : null;
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lat'] = lat;
    data['longi'] = longi;
    data['nom'] = nom;
    if (commune != null) {
      data['commune'] = commune!.toJson();
    }
    data['description'] = description;
    return data;
  }
}
