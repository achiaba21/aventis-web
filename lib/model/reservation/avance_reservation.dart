class AvanceReservation {
  int? id;
  double? montant;
  DateTime? datePaiement;
  double? frais;

  AvanceReservation({this.id, this.montant, this.datePaiement, this.frais});

  AvanceReservation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    montant = json['montant'];
    datePaiement =
        json['datePaiement'] != null
            ? DateTime.parse(json['datePaiement'])
            : null;
    frais = json['frais'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['montant'] = montant;
    data['datePaiement'] = datePaiement?.toIso8601String();
    data['frais'] = frais;
    return data;
  }
}
