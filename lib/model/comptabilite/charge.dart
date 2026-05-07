import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';

class Charge {
  int? id;
  int? appartementId; // OBLIGATOIRE - la charge est liée à un appartement
  String? appartementNom; // Nom de l'appartement (retourné par le serveur)
  int? residenceId; // ID de la résidence (déduit via appartement, retourné par le serveur)
  String? residenceNom; // Nom de la résidence (retourné par le serveur)
  String? typeChargeValue;
  String? libelle;
  double? montant;
  String? frequenceValue;
  DateTime? dateDebut; // Date de début pour les charges récurrentes
  DateTime? dateEcheance; // Prochaine échéance
  DateTime? datePaiement;
  bool? estPaye;
  bool? estRecurrent;
  String? notes;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Getters pour les enums
  TypeCharge get typeCharge => TypeChargeExtension.fromString(typeChargeValue ?? 'autre');
  FrequenceCharge get frequence => FrequenceChargeExtension.fromString(frequenceValue ?? 'mensuel');

  // Setters pour les enums
  set typeCharge(TypeCharge value) => typeChargeValue = value.value;
  set frequence(FrequenceCharge value) => frequenceValue = value.value;

  Charge({
    this.id,
    this.appartementId,
    this.appartementNom,
    this.residenceId,
    this.residenceNom,
    this.typeChargeValue,
    this.libelle,
    this.montant,
    this.frequenceValue,
    this.dateDebut,
    this.dateEcheance,
    this.datePaiement,
    this.estPaye,
    this.estRecurrent,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Constructeur avec enums directement
  Charge.create({
    this.id,
    required this.appartementId, // OBLIGATOIRE
    this.appartementNom,
    this.residenceId,
    this.residenceNom,
    TypeCharge? typeCharge,
    this.libelle,
    this.montant,
    FrequenceCharge? frequence,
    this.dateDebut,
    this.dateEcheance,
    this.datePaiement,
    this.estPaye = false,
    this.estRecurrent = true,
    this.notes,
    DateTime? createdAt,
  }) {
    typeChargeValue = typeCharge?.value ?? TypeCharge.autre.value;
    frequenceValue = frequence?.value ?? FrequenceCharge.mensuel.value;
    this.createdAt = createdAt ?? DateTime.now();
    updatedAt = DateTime.now();

    // Si récurrent et pas d'échéance, calculer la première échéance
    if (estRecurrent == true && dateDebut != null && dateEcheance == null) {
      dateEcheance = _calculerProchaineEcheance(dateDebut!, frequence ?? FrequenceCharge.mensuel);
    }
  }

  /// Calcule la prochaine échéance basée sur la date de début et la fréquence
  static DateTime _calculerProchaineEcheance(DateTime dateDebut, FrequenceCharge frequence) {
    final now = DateTime.now();
    var echeance = dateDebut;

    // Avancer jusqu'à la prochaine échéance future
    while (echeance.isBefore(now)) {
      echeance = _ajouterIntervalle(echeance, frequence);
    }

    return echeance;
  }

  /// Ajoute l'intervalle de fréquence à une date
  static DateTime _ajouterIntervalle(DateTime date, FrequenceCharge frequence) {
    switch (frequence) {
      case FrequenceCharge.ponctuel:
        return date;
      case FrequenceCharge.mensuel:
        return DateTime(date.year, date.month + 1, date.day);
      case FrequenceCharge.bimestriel:
        return DateTime(date.year, date.month + 2, date.day);
      case FrequenceCharge.trimestriel:
        return DateTime(date.year, date.month + 3, date.day);
      case FrequenceCharge.semestriel:
        return DateTime(date.year, date.month + 6, date.day);
      case FrequenceCharge.annuel:
        return DateTime(date.year + 1, date.month, date.day);
    }
  }

  Charge.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    appartementId = json['appartementId'] as int?;
    appartementNom = json['appartementNom'] as String?;
    residenceId = json['residenceId'] as int?;
    residenceNom = json['residenceNom'] as String?;
    typeChargeValue = json['typeCharge'] as String?;
    libelle = json['libelle'] as String?;
    montant = _parseDouble(json['montant']);
    frequenceValue = json['frequence'] as String?;
    dateDebut = _parseDateTime(json['dateDebut']);
    dateEcheance = _parseDateTime(json['dateEcheance']);
    datePaiement = _parseDateTime(json['datePaiement']);
    estPaye = json['estPaye'] as bool? ?? false;
    estRecurrent = json['estRecurrent'] as bool? ?? true;
    notes = json['notes'] as String?;
    createdAt = _parseDateTime(json['createdAt']);
    updatedAt = _parseDateTime(json['updatedAt']);
  }

  /// Helper pour parser les valeurs numériques de façon sécurisée
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Helper pour parser les dates de façon sécurisée
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'appartementId': appartementId, // OBLIGATOIRE pour création/mise à jour
      'typeCharge': typeChargeValue,
      'libelle': libelle,
      'montant': montant,
      'frequence': frequenceValue,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateEcheance': dateEcheance?.toIso8601String(),
      'datePaiement': datePaiement?.toIso8601String(),
      'estPaye': estPaye,
      'estRecurrent': estRecurrent,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Charge copyWith({
    int? id,
    int? appartementId,
    String? appartementNom,
    int? residenceId,
    String? residenceNom,
    TypeCharge? typeCharge,
    String? libelle,
    double? montant,
    FrequenceCharge? frequence,
    DateTime? dateDebut,
    DateTime? dateEcheance,
    DateTime? datePaiement,
    bool? estPaye,
    bool? estRecurrent,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Charge(
      id: id ?? this.id,
      appartementId: appartementId ?? this.appartementId,
      appartementNom: appartementNom ?? this.appartementNom,
      residenceId: residenceId ?? this.residenceId,
      residenceNom: residenceNom ?? this.residenceNom,
      typeChargeValue: typeCharge?.value ?? typeChargeValue,
      libelle: libelle ?? this.libelle,
      montant: montant ?? this.montant,
      frequenceValue: frequence?.value ?? frequenceValue,
      dateDebut: dateDebut ?? this.dateDebut,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      datePaiement: datePaiement ?? this.datePaiement,
      estPaye: estPaye ?? this.estPaye,
      estRecurrent: estRecurrent ?? this.estRecurrent,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Vérifie si la charge est en retard
  bool get estEnRetard {
    if (estPaye == true || dateEcheance == null) return false;
    return DateTime.now().isAfter(dateEcheance!);
  }

  /// Vérifie si l'échéance approche (dans les 7 prochains jours)
  bool get echeanceProche {
    if (estPaye == true || dateEcheance == null) return false;
    final diff = dateEcheance!.difference(DateTime.now()).inDays;
    return diff >= 0 && diff <= 7;
  }

  /// Calcule le montant mensuel équivalent
  double get montantMensuel {
    if (montant == null) return 0;
    return frequence.montantMensuel(montant!);
  }

  /// Label complet pour affichage
  String get labelComplet {
    if (libelle != null && libelle!.isNotEmpty) {
      return libelle!;
    }
    return typeCharge.label;
  }

  @override
  String toString() {
    return 'Charge{id: $id, type: ${typeCharge.label}, montant: $montant, residence: $residenceId}';
  }
}
