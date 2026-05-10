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

  static fromJsonAll(Map<String, dynamic> json) {
    deboger(["****************************************", json]);

    // Discrimination prioritaire par le champ `type` (canonique côté backend).
    final type = (json['type'] as String?)?.toLowerCase();
    switch (type) {
      case 'locataire':
        return Locataire.fromJson(json);
      case 'proprietaire':
        return Proprietaire.fromJson(json);
      case 'demarcheur':
        return Demarcheur.fromJson(json);
    }

    // Fallback : flags booléens. Comparer `== true` (et non `!= null`) pour
    // éviter qu'un flag à `false` ne soit considéré comme un match positif.
    if (json['locataire'] == true) return Locataire.fromJson(json);
    if (json['proprietaire'] == true) return Proprietaire.fromJson(json);
    if (json['demarcheur'] == true) return Demarcheur.fromJson(json);
    return Client.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['client'] = client;

    return data;
  }
}
