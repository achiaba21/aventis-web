abstract class Compte {
  int? id;
  bool? actif;
  double? solde;
  String? numero;
  String? type;

  Compte({this.id, this.actif, this.solde, this.numero, this.type});

  Compte.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    actif = json['actif'];
    solde = json['solde']?.toDouble();
    numero = json['numero'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['actif'] = actif;
    data['solde'] = solde;
    data['numero'] = numero;
    if (type != null) {
      data['type'] = type;
    }
    return data;
  }
}
