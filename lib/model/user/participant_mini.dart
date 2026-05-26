/// Vue compacte d'un utilisateur — exposée par le backend dans les listings
/// et listes courtes : 4 champs identitaires (`id`, `prenom`, `nom`,
/// `telephone`) sans les champs profil étendus.
///
/// Utilisé par :
/// - `DemandePartenariat.demarcheur` / `.proprietaire`
/// - `Appartement.proprietaire` (mini-proprio sur le DTO démarcheur depuis
///   backend 2026-05-18 — cf. `AppartementForDemarcheurDto.ProprietaireMini`)
class ParticipantMini {
  final int id;
  final String prenom;
  final String nom;
  final String telephone;

  const ParticipantMini({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
  });

  factory ParticipantMini.fromJson(Map<String, dynamic> json) {
    return ParticipantMini(
      id: json['id'] as int,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
      };

  /// Nom complet « prénom nom » — fallback `'Utilisateur'` si tout est vide.
  String get fullName {
    final full = '$prenom $nom'.trim();
    return full.isNotEmpty ? full : 'Utilisateur';
  }

  /// Initiale (1er char du prénom) — fallback `'?'` si prénom vide.
  String get initiale => prenom.isNotEmpty ? prenom[0].toUpperCase() : '?';
}
