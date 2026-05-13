import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';

/// Charge enregistrée par le proprio.
///
/// Sémantique post-2026-05-13 : **chaque charge représente un paiement déjà
/// effectué**. Les notions `estPaye`, `datePaiement`, `estEnRetard` ont été
/// retirées du backend ; toute charge en base est par définition payée.
///
/// `dateEcheance` ne sert plus qu'à projeter la prochaine occurrence pour les
/// charges récurrentes (vu par `AlerteChargeResponse.aVenir`). Côté Flutter,
/// la sémantique courante est : `dateDebut` = date du paiement enregistré.
class Charge {
  int? id;
  int? appartementId; // OBLIGATOIRE - la charge est liée à un appartement
  String? appartementNom; // Nom de l'appartement (retourné par le serveur)
  String? typeChargeValue;
  String? libelle;
  double? montant;
  String? frequenceValue;
  DateTime? dateDebut;
  DateTime? dateEcheance;
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
    this.typeChargeValue,
    this.libelle,
    this.montant,
    this.frequenceValue,
    this.dateDebut,
    this.dateEcheance,
    this.estRecurrent,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Constructeur avec enums directement.
  ///
  /// Invariant garanti : `estRecurrent` est dérivé de `frequence` (ponctuel
  /// ⟹ false, sinon true). Une charge ponctuelle a `dateEcheance = null`
  /// (la `dateDebut` fait office de date du paiement).
  Charge.create({
    this.id,
    required this.appartementId,
    this.appartementNom,
    TypeCharge? typeCharge,
    this.libelle,
    this.montant,
    FrequenceCharge? frequence,
    this.dateDebut,
    DateTime? dateEcheance,
    this.notes,
    DateTime? createdAt,
  }) {
    final freq = frequence ?? FrequenceCharge.mensuel;
    typeChargeValue = typeCharge?.value ?? TypeCharge.autre.value;
    frequenceValue = freq.value;
    estRecurrent = freq.isRecurrente;
    this.createdAt = createdAt ?? DateTime.now();
    updatedAt = DateTime.now();

    if (freq.isPonctuel) {
      this.dateEcheance = null;
    } else if (dateEcheance != null) {
      this.dateEcheance = dateEcheance;
    } else if (dateDebut != null) {
      this.dateEcheance = _calculerProchaineEcheance(dateDebut!, freq);
    }
  }

  static DateTime _calculerProchaineEcheance(DateTime dateDebut, FrequenceCharge frequence) {
    final now = DateTime.now();
    var echeance = dateDebut;
    while (echeance.isBefore(now)) {
      echeance = _ajouterIntervalle(echeance, frequence);
    }
    return echeance;
  }

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
    typeChargeValue = json['typeCharge'] as String?;
    libelle = json['libelle'] as String?;
    montant = _parseDouble(json['montant']);
    frequenceValue = json['frequence'] as String?;
    dateDebut = _parseDateTime(json['dateDebut']);
    dateEcheance = _parseDateTime(json['dateEcheance']);
    estRecurrent = json['estRecurrent'] as bool? ?? true;
    notes = json['notes'] as String?;
    createdAt = _parseDateTime(json['createdAt']);
    updatedAt = _parseDateTime(json['updatedAt']);
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

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
      'appartementId': appartementId,
      'typeCharge': typeChargeValue,
      'libelle': libelle,
      'montant': montant,
      'frequence': frequenceValue,
      'dateDebut': dateDebut?.toIso8601String(),
      'dateEcheance': dateEcheance?.toIso8601String(),
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
    TypeCharge? typeCharge,
    String? libelle,
    double? montant,
    FrequenceCharge? frequence,
    DateTime? dateDebut,
    DateTime? dateEcheance,
    bool? estRecurrent,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Charge(
      id: id ?? this.id,
      appartementId: appartementId ?? this.appartementId,
      appartementNom: appartementNom ?? this.appartementNom,
      typeChargeValue: typeCharge?.value ?? typeChargeValue,
      libelle: libelle ?? this.libelle,
      montant: montant ?? this.montant,
      frequenceValue: frequence?.value ?? frequenceValue,
      dateDebut: dateDebut ?? this.dateDebut,
      dateEcheance: dateEcheance ?? this.dateEcheance,
      estRecurrent: estRecurrent ?? this.estRecurrent,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
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
    return 'Charge{id: $id, type: ${typeCharge.label}, montant: $montant, appart: $appartementId}';
  }
}
