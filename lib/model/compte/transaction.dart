class Transaction {
  int? id;
  double? montant;
  String? type; // CREDIT, DEBIT
  String? description;
  DateTime? dateTransaction;
  String? statut; // EFFECTUE, EN_ATTENTE, ANNULE
  int? compteId;

  Transaction({
    this.id,
    this.montant,
    this.type,
    this.description,
    this.dateTransaction,
    this.statut,
    this.compteId,
  });

  /// Vérifie si c'est un crédit (argent reçu)
  bool get isCredit => type == 'CREDIT';

  /// Vérifie si c'est un débit (argent sorti)
  bool get isDebit => type == 'DEBIT';

  /// Vérifie si la transaction est effectuée
  bool get isEffectue => statut == 'EFFECTUE';

  /// Vérifie si la transaction est en attente
  bool get isEnAttente => statut == 'EN_ATTENTE';

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      montant: json['montant']?.toDouble(),
      type: json['type'],
      description: json['description'],
      dateTransaction: json['dateTransaction'] != null
          ? DateTime.parse(json['dateTransaction'])
          : null,
      statut: json['statut'],
      compteId: json['compteId'] ?? json['compte']?['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'type': type,
      'description': description,
      'dateTransaction': dateTransaction?.toIso8601String(),
      'statut': statut,
      'compteId': compteId,
    };
  }

  @override
  String toString() {
    return 'Transaction(id: $id, type: $type, montant: $montant, description: $description)';
  }
}
