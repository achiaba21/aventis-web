class User {
  int? id;
  String? nom;
  String? prenom;
  String? email;
  String? telephone;
  String? password;
  DateTime? age;
  String? type;
  DateTime? createdAt;
  String? imgUrl;

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
    this.imgUrl,
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
    imgUrl = json['imgUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nom'] = nom;
    data['prenom'] = prenom;
    data['email'] = email;
    data['telephone'] = telephone;
    data['password'] = password;
    data['age'] = age?.toIso8601String();
    data['type'] = type;
    data['imgUrl'] = imgUrl;
    return data;
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
