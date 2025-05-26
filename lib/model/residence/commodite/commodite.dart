import 'package:flutter/widgets.dart';
import 'package:web_flutter/model/residence/commodite/chauffe_eau.dart';
import 'package:web_flutter/model/residence/commodite/climatiseur.dart';
import 'package:web_flutter/model/residence/commodite/wash_machine.dart';

abstract class Commodite {
  int? id;
  String? nom;
  String? description;

  String? get svgPath;
  IconData? get icon;

  Commodite({this.id, this.nom, this.description});

  Commodite.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    description = json['description'];
  }

  static Commodite fromJsonAll(Map<String, dynamic> json) {
    if (ChauffeEau.fromJson(json).chauffeEau != null) {
      return ChauffeEau.fromJson(json);
    }
    if (Climatiseur.fromJson(json).climatiseur != null) {
      return Climatiseur.fromJson(json);
    }

    return MachineALaver.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['description'] = description;
    return data;
  }
}
