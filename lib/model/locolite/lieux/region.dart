import 'package:asfar/model/locolite/lieux/lieux.dart';
import 'package:asfar/model/locolite/lieux/pays.dart';
import 'package:asfar/model/locolite/lieux/ville.dart';

class Region extends Lieux {
  bool? region = true;
  Pays? pays;
  List<Ville>? villes;

  Region({
    super.id,
    super.nom,
    super.code,
    String? type,
    this.pays,
    this.region,
    this.villes,
  }) : super(type: type ?? "Region");

  Region.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    pays = json['pays'] != null ? Pays.fromJson(json['pays']) : null;
    region = json['region'];
    villes = json['villes'] != null
        ? List<Ville>.from(json['villes'].map((x) => Ville.fromJson(x)))
        : null;
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
    if (villes != null) {
      data['villes'] = villes!.map((x) => x.toJson()).toList();
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
