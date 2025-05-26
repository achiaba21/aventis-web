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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['lat'] = this.lat;
    data['longi'] = this.longi;
    data['nom'] = this.nom;
    data['commune'] = this.commune;
    data['description'] = this.description;
    return data;
  }
}
