class User {
  int? id;
  String? nom;
  String? prenom;
  String? email;
  String? telephone;
  String? password;
  int? age;
  String? type;
  DateTime? createdAt;

  String get nature => "user";

  String get fullName {
    return "${nom ?? ""} ${prenom ?? ""}";
  }

  String get credential => email ?? telephone ?? "";

  User({
    this.id,
    this.nom,
    this.prenom,
    this.email,
    this.telephone,
    this.password,
    this.age,
    this.type,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nom = json['nom'];
    prenom = json['prenom'];
    email = json['email'];
    telephone = json['telephone'];
    password = json['password'];
    age = json['age'];
    type = json['type'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['email'] = email;
    data['telephone'] = telephone;
    data['password'] = password;
    data['age'] = age;
    data['type'] = type;
    return data;
  }
}
