import 'package:web_flutter/model/user/client.dart';

class Locataire extends Client {
  bool? locataire;

  Locataire({
    super.id,
    super.nom,
    super.prenom,
    super.email,
    super.telephone,
    super.password,
    super.age,
    String? type,
    super.client = null,
    this.locataire = true,
  }) : super(type: type ?? 'Locataire');

  Locataire.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    locataire = json['locataire'];
  }

  @override
  // TODO: implement nature
  String get nature => "client";

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['locataire'] = locataire;
    return data;
  }
}
