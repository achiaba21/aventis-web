import 'package:asfar/model/locolite/lieux/commune.dart';
import 'package:asfar/model/locolite/lieux/lieux.dart';
import 'package:asfar/model/locolite/lieux/region.dart';

class Ville extends Lieux {
  Region? region;
  bool? ville = true;
  List<Commune>? communes;

  Ville({
    super.id,
    super.nom,
    super.code,
    String? type,
    this.region,
    this.ville,
    this.communes,
  }) : super(type: type ?? "Ville");

  Ville.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    region = json['region'] != null ? Region.fromJson(json['region']) : null;
    ville = json['ville'];
    communes = json['communes'] != null
        ? List<Commune>.from(json['communes'].map((x) => Commune.fromJson(x)))
        : null;
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
    if (communes != null) {
      data['communes'] = communes!.map((x) => x.toJson()).toList();
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
