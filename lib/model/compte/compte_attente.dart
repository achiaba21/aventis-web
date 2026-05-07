class CompteAttente {
  int? id;
  double? solde;
  double? montantVerrouille;

  CompteAttente({
    this.id,
    this.solde,
    this.montantVerrouille,
  });

  factory CompteAttente.fromJson(Map<String, dynamic> json) {
    return CompteAttente(
      id: json['id'],
      solde: json['solde']?.toDouble(),
      montantVerrouille: json['montantVerrouille']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'solde': solde,
      'montantVerrouille': montantVerrouille,
    };
  }

  @override
  String toString() {
    return 'CompteAttente(id: $id, solde: $solde, montantVerrouille: $montantVerrouille)';
  }
}
