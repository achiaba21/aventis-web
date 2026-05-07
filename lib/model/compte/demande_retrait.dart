class DemandeRetrait {
  int? id;
  double? montant;
  String? statut; // EN_ATTENTE, APPROUVE, REFUSE, TRAITE
  DateTime? dateDemande;
  DateTime? dateTraitement;
  String? motifRefus;
  int? compteId;

  DemandeRetrait({
    this.id,
    this.montant,
    this.statut,
    this.dateDemande,
    this.dateTraitement,
    this.motifRefus,
    this.compteId,
  });

  /// Vérifie si la demande est en attente
  bool get isEnAttente => statut == 'EN_ATTENTE';

  /// Vérifie si la demande est approuvée
  bool get isApprouve => statut == 'APPROUVE';

  /// Vérifie si la demande est refusée
  bool get isRefuse => statut == 'REFUSE';

  /// Vérifie si la demande est traitée (paiement effectué)
  bool get isTraite => statut == 'TRAITE';

  factory DemandeRetrait.fromJson(Map<String, dynamic> json) {
    return DemandeRetrait(
      id: json['id'],
      montant: json['montant']?.toDouble(),
      statut: json['statut'],
      dateDemande: json['dateDemande'] != null
          ? DateTime.parse(json['dateDemande'])
          : null,
      dateTraitement: json['dateTraitement'] != null
          ? DateTime.parse(json['dateTraitement'])
          : null,
      motifRefus: json['motifRefus'],
      compteId: json['compteId'] ?? json['compte']?['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'montant': montant,
      'statut': statut,
      'dateDemande': dateDemande?.toIso8601String(),
      'dateTraitement': dateTraitement?.toIso8601String(),
      'motifRefus': motifRefus,
      'compteId': compteId,
    };
  }

  @override
  String toString() {
    return 'DemandeRetrait(id: $id, montant: $montant, statut: $statut)';
  }
}
