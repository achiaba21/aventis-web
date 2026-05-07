import 'package:asfar/config/app_propertie.dart';
import 'package:asfar/model/user/demarcheur.dart';
import 'package:asfar/model/user/locataire.dart';
import 'package:asfar/model/user/proprietaire.dart';
import 'package:asfar/model/user/user.dart';
import 'package:asfar/util/function.dart';

class Client extends User {
  bool? client;

  Client({
    super.id,
    super.nom,
    super.prenom,
    super.email,
    super.telephone,
    super.password,
    super.age,
    super.type,
    this.client = true,
  });

  Client.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    client = json['client'];
  }

  String get photoUser => "$serveur/$imgUrl";

  static fromJsonAll(Map<String, dynamic> json){
    deboger(["****************************************",json]);
    if (Locataire.fromJson(json).locataire != null) {
      return Locataire.fromJson(json);
    }
    if (Proprietaire.fromJson(json).proprietaire != null) {
      return Proprietaire.fromJson(json);
    }
    if (Demarcheur.fromJson(json).demarcheur != null) {
      return Demarcheur.fromJson(json);
    }
    return Client.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['client'] = client;

    return data;
  }
}
