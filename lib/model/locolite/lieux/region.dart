import 'package:web_flutter/model/locolite/lieux/lieux.dart';
import 'package:web_flutter/model/locolite/lieux/pays.dart';

class Region extends Lieux {
  bool? region = true;
  Pays? pays;

  Region({super.id, super.nom, String? type, this.pays, this.region})
    : super(type: type ?? "Region");

  Region.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    pays = json['pays'] != null ? Pays.fromJson(json['pays']) : null;
    region = json['region'];
    type = type ?? "Region";
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (pays != null) {
      data['pays'] = pays!.toJson();
    }
    if (region != null) {
      data['region'] = region;
    }
    return data;
  }

  @override
  Lieux? getParent() {
    return pays;
  }

  @override
  bool isInclue(Lieux lieux) {
    if (lieux.id == null || id == null) return false;
    if (lieux.id == id) return true;
    return getParent()?.isInclue(lieux) ?? false;
  }
}
