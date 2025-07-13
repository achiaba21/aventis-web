class Address {
  int? id;
  double? lat;
  double? longi;
  String? nom;
  String? commune;
  String? description;

  Address({
    this.id,
    this.lat,
    this.longi,
    this.nom,
    this.commune,
    this.description,
  });

  Address.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    lat = json['lat'];
    longi = json['longi'];
    nom = json['nom'];
    commune = json['commune'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['lat'] = lat;
    data['longi'] = longi;
    data['nom'] = nom;
    data['commune'] = commune;
    data['description'] = description;
    return data;
  }
}
