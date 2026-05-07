abstract class Lieux {
  int? id;
  String? nom;
  String? type;
  String? code;

  Lieux({this.id, this.nom, this.type, this.code});

  Lieux.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    type = json['type'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (nom != null) data['nom'] = nom;
    if (type != null) data['type'] = type;
    if (code != null) data['code'] = code;
    return data;
  }

  // Méthodes abstraites à implémenter dans les classes filles
  Lieux? getParent();
  bool isInclue(Lieux lieux);
}
