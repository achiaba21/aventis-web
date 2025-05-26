import 'package:web_flutter/model/locolite/lieux/lieux.dart';
import 'package:web_flutter/model/locolite/lieux/region.dart';

class Ville extends Lieux {
  Region? region;
  bool? ville = true;

  Ville({int? id, String? nom, String? type, this.region, this.ville})
    : super(id: id, nom: nom, type: type ?? "Ville");

  Ville.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    region = json['region'] != null ? Region.fromJson(json['region']) : null;
    ville = json['ville'];
    type = type ?? "Ville";
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (region != null) {
      data['region'] = region!.toJson();
    }
    if (ville != null) {
      data['ville'] = ville;
    }
    return data;
  }

  @override
  Lieux? getParent() {
    return region;
  }

  @override
  bool isInclue(Lieux lieux) {
    if (lieux.id == null || id == null) return false;
    if (lieux.id == id) return true;
    return getParent()?.isInclue(lieux) ?? false;
  }
}
