import 'package:web_flutter/model/user/client.dart';

class Proprietaire extends Client {
  bool? proprietaire;

  Proprietaire({
    super.id,
    super.nom,
    super.prenom,
    super.email,
    super.telephone,
    super.password,
    super.age,
    String? type,
    super.client = null,
    this.proprietaire = true,
  }) : super(type: type ?? 'Proprietaire');

  Proprietaire.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    proprietaire = json['proprietaire'];
  }

  @override
  // TODO: implement nature
  String get nature => "Proprio";

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['proprietaire'] = proprietaire;
    return data;
  }
}
