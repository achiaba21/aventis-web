import 'package:asfar/model/partenariat/statut_partenariat.dart';
import 'package:asfar/model/user/participant_mini.dart';

/// Demande de partenariat entre un démarcheur et un propriétaire.
///
/// Modèle aligné sur le DTO backend uniforme depuis 2026-05-17 — les 2 sous-
/// objets (`demarcheur`, `proprietaire`) sont garantis typés `ParticipantMini`
/// sur tous les endpoints.
class DemandePartenariat {
  final int id;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ParticipantMini demarcheur;
  final ParticipantMini proprietaire;
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
      demarcheur: ParticipantMini.fromJson(
        Map<String, dynamic>.from(json['demarcheur'] as Map),
      ),
      proprietaire: ParticipantMini.fromJson(
        Map<String, dynamic>.from(json['proprietaire'] as Map),
      ),
      statut: StatutPartenariat.fromString(json['statut'] as String? ?? ''),
      repondueAt: json['repondueAt'] != null
          ? DateTime.parse(json['repondueAt'] as String)
          : null,
    );
  }

  String get nomDemarcheur =>
      demarcheur.fullName == 'Utilisateur' ? 'Démarcheur' : demarcheur.fullName;
  String get telephoneDemarcheur => demarcheur.telephone;
  String get initDemarcheur =>
      demarcheur.prenom.isNotEmpty ? demarcheur.initiale : 'D';

  String get nomProprietaire => proprietaire.fullName == 'Utilisateur'
      ? 'Propriétaire'
      : proprietaire.fullName;
  String get telephoneProprietaire => proprietaire.telephone;
  String get initProprietaire =>
      proprietaire.prenom.isNotEmpty ? proprietaire.initiale : 'P';
}
