abstract class Lieux {
  int? id;
  String? nom;
  String? type;

  Lieux({this.id, this.nom, this.type});

  Lieux.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (nom != null) data['nom'] = nom;
    if (type != null) data['type'] = type;
    return data;
  }

  // Méthodes abstraites à implémenter dans les classes filles
  Lieux? getParent();
  bool isInclue(Lieux lieux);
}
