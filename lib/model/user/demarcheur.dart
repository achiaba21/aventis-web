import 'package:asfar/model/user/client.dart';

class Demarcheur extends Client {
  bool? demarcheur;
  DateTime? dateNaissance;

  Demarcheur({
    super.id,
    super.nom,
    super.prenom,
    super.email,
    super.telephone,
    super.password,
    super.age,
    String? type,
    super.client = null,
    this.demarcheur = true,
    this.dateNaissance,
  }) : super(type: type ?? 'Demarcheur');

  Demarcheur.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    demarcheur = json['demarcheur'];
    dateNaissance = json['dateNaissance'] != null
        ? DateTime.tryParse(json['dateNaissance'].toString())
        : null;
  }

  @override
  String get nature => 'Demarcheur';

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['demarcheur'] = demarcheur;
    if (dateNaissance != null) {
      data['dateNaissance'] = dateNaissance!.toIso8601String();
    }
    return data;
  }

  @override
  String toString() => toJson().toString();
}
