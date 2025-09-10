import 'package:web_flutter/config/app_propertie.dart';
import 'package:web_flutter/model/user/user.dart';

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

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['client'] = client;

    return data;
  }
}
