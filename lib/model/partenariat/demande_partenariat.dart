import 'package:asfar/model/partenariat/statut_partenariat.dart';

class DemandePartenariat {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> demarcheur;
  final Map<String, dynamic> proprietaire;
  final StatutPartenariat statut;
  final DateTime? repondueAt;

  const DemandePartenariat({
    required this.id,
    required this.createdAt,
    this.updatedAt,
    required this.demarcheur,
    required this.proprietaire,
    required this.statut,
    this.repondueAt,
  });

  factory DemandePartenariat.fromJson(Map<String, dynamic> json) {
    return DemandePartenariat(
      id: json['id'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      demarcheur: json['demarcheur'] as Map<String, dynamic>? ?? {},
      proprietaire: json['proprietaire'] as Map<String, dynamic>? ?? {},
      statut: StatutPartenariat.fromString(json['statut'] as String? ?? ''),
      repondueAt: json['repondueAt'] != null
          ? DateTime.parse(json['repondueAt'] as String)
          : null,
    );
  }

  String get nomDemarcheur {
    final prenom = demarcheur['prenom'] as String? ?? '';
    final nom = demarcheur['nom'] as String? ?? '';
    return '$prenom $nom'.trim().isNotEmpty ? '$prenom $nom'.trim() : 'Démarcheur';
  }

  String get telephoneDemarcheur =>
      demarcheur['telephone'] as String? ?? '';

  String get initDemarcheur {
    final prenom = demarcheur['prenom'] as String? ?? '';
    return prenom.isNotEmpty ? prenom[0].toUpperCase() : 'D';
  }

  String get nomProprietaire {
    final prenom = proprietaire['prenom'] as String? ?? '';
    final nom = proprietaire['nom'] as String? ?? '';
    return '$prenom $nom'.trim().isNotEmpty ? '$prenom $nom'.trim() : 'Propriétaire';
  }

  String get telephoneProprietaire =>
      proprietaire['telephone'] as String? ?? '';

  String get initProprietaire {
    final prenom = proprietaire['prenom'] as String? ?? '';
    return prenom.isNotEmpty ? prenom[0].toUpperCase() : 'P';
  }
}
