import 'package:web_flutter/model/user/user.dart';

class Client extends User {
  String? imgUrl;
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
    this.imgUrl,
  });

  Client.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    client = json['client'];
    imgUrl = json['imgUrl'];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['client'] = client;
    data['imgUrl'] = imgUrl;
    return data;
  }
}
