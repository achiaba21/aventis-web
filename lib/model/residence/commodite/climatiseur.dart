import 'package:flutter/src/widgets/icon_data.dart';
import 'package:web_flutter/model/residence/commodite/commodite.dart';

class Climatiseur extends Commodite {
  bool? climatiseur;

  Climatiseur({super.nom, super.description, this.climatiseur = true});

  Climatiseur.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    climatiseur = json['climatiseur'] ?? true;
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['climatiseur'] = climatiseur;
    return data;
  }

  @override
  // TODO: implement icon
  IconData? get icon => throw UnimplementedError();

  @override
  // TODO: implement svgPath
  String? get svgPath => throw UnimplementedError();
}
