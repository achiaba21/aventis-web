/// Type de reçu
enum ReceiptType {
  acompte('ACOMPTE'),
  definitif('DEFINITIF');

  const ReceiptType(this.value);
  final String value;

  static ReceiptType fromString(String value) {
    return ReceiptType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => ReceiptType.acompte,
    );
  }

  String get label {
    switch (this) {
      case ReceiptType.acompte:
        return 'Acompte';
      case ReceiptType.definitif:
        return 'Définitif';
    }
  }
}

/// Modèle de reçu de réservation
class Receipt {
  final String? numeroRecu;
  final ReceiptType typeRecu;
  final DateTime? dateEmission;
  final String? locataireNom;
  final String? locatairePrenom;
  final String? appartementTitre;
  final String? residenceNom;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final int? nombreJours;
  final double? montantTotal;
  final double? montantVerse;
  final double? montantRestant;
  final double? fraisService;
  final String? devise;
  final String? moyenPaiement;
  final List<ReceiptLineItem> lignes;

  Receipt({
    this.numeroRecu,
    this.typeRecu = ReceiptType.acompte,
    this.dateEmission,
    this.locataireNom,
    this.locatairePrenom,
    this.appartementTitre,
    this.residenceNom,
    this.dateDebut,
    this.dateFin,
    this.nombreJours,
    this.montantTotal,
    this.montantVerse,
    this.montantRestant,
    this.fraisService,
    this.devise,
    this.moyenPaiement,
    this.lignes = const [],
  });

  /// Nom complet du locataire
  String get locataireFullName {
    final nom = locataireNom ?? '';
    final prenom = locatairePrenom ?? '';
    return '$nom $prenom'.trim();
  }

  /// Indique si le paiement est complet
  bool get isPaidInFull => (montantRestant ?? 0) <= 0;

  /// Pourcentage payé
  double get pourcentagePaye {
    if (montantTotal == null || montantTotal == 0) return 0;
    return ((montantVerse ?? 0) / montantTotal!) * 100;
  }

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      numeroRecu: json['numeroRecu'],
      typeRecu: json['typeRecu'] != null
          ? ReceiptType.fromString(json['typeRecu'])
          : ReceiptType.acompte,
      dateEmission: json['dateEmission'] != null
          ? DateTime.parse(json['dateEmission'])
          : null,
      locataireNom: json['locataireNom'],
      locatairePrenom: json['locatairePrenom'],
      appartementTitre: json['appartementTitre'],
      residenceNom: json['residenceNom'],
      dateDebut: json['dateDebut'] != null
          ? DateTime.parse(json['dateDebut'])
          : null,
      dateFin: json['dateFin'] != null
          ? DateTime.parse(json['dateFin'])
          : null,
      nombreJours: json['nombreJours'],
      montantTotal: json['montantTotal']?.toDouble(),
      montantVerse: json['montantVerse']?.toDouble(),
      montantRestant: json['montantRestant']?.toDouble(),
      fraisService: json['fraisService']?.toDouble(),
      devise: json['devise'],
      moyenPaiement: json['moyenPaiement'],
      lignes: json['lignes'] != null
          ? (json['lignes'] as List)
              .map((e) => ReceiptLineItem.fromJson(e))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numeroRecu': numeroRecu,
      'typeRecu': typeRecu.value,
      'dateEmission': dateEmission?.toIso8601String(),
      'locataireNom': locataireNom,
      'locatairePrenom': locatairePrenom,
      'appartementTitre': appartementTitre,
      'residenceNom': residenceNom,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateFin': dateFin?.toIso8601String(),
      'nombreJours': nombreJours,
      'montantTotal': montantTotal,
      'montantVerse': montantVerse,
      'montantRestant': montantRestant,
      'fraisService': fraisService,
      'devise': devise,
      'moyenPaiement': moyenPaiement,
      'lignes': lignes.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => 'Receipt($numeroRecu, $typeRecu, $montantVerse/$montantTotal)';
}

/// Ligne de détail d'un reçu
class ReceiptLineItem {
  final String? description;
  final int? quantite;
  final double? prixUnitaire;
  final double? montant;

  ReceiptLineItem({
    this.description,
    this.quantite,
    this.prixUnitaire,
    this.montant,
  });

  factory ReceiptLineItem.fromJson(Map<String, dynamic> json) {
    return ReceiptLineItem(
      description: json['description'],
      quantite: json['quantite'],
      prixUnitaire: json['prixUnitaire']?.toDouble(),
      montant: json['montant']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'quantite': quantite,
      'prixUnitaire': prixUnitaire,
      'montant': montant,
    };
  }

  @override
  String toString() => 'ReceiptLineItem($description, $quantite x $prixUnitaire = $montant)';
}
