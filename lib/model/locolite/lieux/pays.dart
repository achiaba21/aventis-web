import 'package:asfar/model/locolite/devise.dart';
import 'package:asfar/model/locolite/lieux/lieux.dart';
import 'package:asfar/model/locolite/lieux/region.dart';

class Pays extends Lieux {
  bool? pays = true;
  Devise? devise;
  List<Region>? regions;

  Pays({
    super.id,
    super.nom,
    super.code,
    String? type,
    this.pays,
    this.devise,
    this.regions,
  }) : super(type: type ?? "Pays");

  Pays.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    pays = json['pays'];
    devise = json['devise'] != null ? Devise.fromJson(json['devise']) : null;
    regions = json['regions'] != null
        ? List<Region>.from(json['regions'].map((x) => Region.fromJson(x)))
        : null;
    type = type ?? "Pays";
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (pays != null) data['pays'] = pays;
    if (devise != null) data['devise'] = devise!.toJson();
    if (regions != null) {
      data['regions'] = regions!.map((x) => x.toJson()).toList();
    }
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
