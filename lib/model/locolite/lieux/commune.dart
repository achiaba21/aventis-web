import 'package:web_flutter/model/locolite/lieux/lieux.dart';
import 'package:web_flutter/model/locolite/lieux/ville.dart';

class Commune extends Lieux {
  bool? commune = true;
  Ville? ville;

  Commune({int? id, String? nom, String? type, this.ville, this.commune})
    : super(id: id, nom: nom, type: type ?? "Commune");

  Commune.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    ville = json['ville'] != null ? Ville.fromJson(json['ville']) : null;
    commune = json['commune'];
    type = type ?? "Commune";
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    if (ville != null) {
      data['ville'] = ville!.toJson();
    }
    if (commune != null) {
      data['commune'] = commune;
    }
    return data;
  }

  @override
  Lieux? getParent() {
    return ville;
  }

  @override
  bool isInclue(Lieux lieux) {
    if (lieux.id == null || id == null) return false;
    if (lieux.id == id) return true;
    return getParent()?.isInclue(lieux) ?? false;
  }
}
