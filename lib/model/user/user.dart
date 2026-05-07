import 'package:hive/hive.dart';
import 'package:asfar/model/user/client.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/model/user/proprietaire.dart';

part 'user.g.dart';

@HiveType(typeId: 2)
class User {
  @HiveField(0)
  int? id;

  @HiveField(1)
  String? nom;

  @HiveField(2)
  String? prenom;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? telephone;

  @HiveField(5)
  String? password;

  @HiveField(6)
  DateTime? age;

  @HiveField(7)
  String? type;

  @HiveField(8)
  DateTime? createdAt;

  @HiveField(9)
  String? imgUrl;

  String get nature => "user";

  String get fullName {
    return "${nom ?? ""} ${prenom ?? ""}".trim();
  }

  /// Vérifie si les informations sensibles (nom/prénom) sont disponibles
  bool get hasSensitiveInfo => (nom != null && nom!.isNotEmpty) ||
                                (prenom != null && prenom!.isNotEmpty);

  /// Vérifie si le téléphone est disponible
  bool get hasPhoneInfo => telephone != null && telephone!.isNotEmpty;

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

  static User fromJsonAll(Map<String, dynamic> json) {
    if (Client.fromJson(json).client != null) {
      return Client.fromJsonAll(json);
    }
    
    return User.fromJson(json);
  }

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
