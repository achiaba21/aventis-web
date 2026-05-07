class Devise {
  int? id;
  String? nom;
  String? symbole;
  String? code;

  Devise({
    this.id,
    this.nom,
    this.symbole,
    this.code,
  });

  static Devise fromJsonAll(Map<String, dynamic> json) {
    return Devise.fromJson(json);
  }

  Devise.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    symbole = json['symbole'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    if (nom != null) data['nom'] = nom;
    if (symbole != null) data['symbole'] = symbole;
    if (code != null) data['code'] = code;
    return data;
  }
}
