import 'package:web_flutter/model/locolite/lieux/lieux.dart';

class Pays extends Lieux {
  bool? pays = true;

  Pays({super.id, super.nom, String? type, this.pays})
    : super(type: type ?? "Pays");

  Pays.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    pays = json['pays'];
    type = type ?? "Pays";
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (pays != null) data['pays'] = pays;
    return data;
  }

  @override
  Lieux? getParent() {
    return null;
  }

  @override
  bool isInclue(Lieux lieux) {
    if (lieux.id == null || id == null) return false;
    return lieux.id == id;
  }
}
