import 'package:asfar/model/compte/compte.dart';
import 'package:asfar/model/compte/compte_attente.dart';

class CompteProprietaire extends Compte {
  CompteAttente? compteAttente;
  int? proprietaireId;

  CompteProprietaire({
    super.id,
    super.actif,
    super.solde,
    super.numero,
    this.compteAttente,
    this.proprietaireId,
  }) : super(type: 'PROPRIETAIRE');

  /// Solde total = solde disponible + solde attente
  double get soldeTotal => (solde ?? 0) + (compteAttente?.solde ?? 0);

  /// Montant verrouillé (non retirable)
  double get montantVerrouille => compteAttente?.montantVerrouille ?? 0;

  /// Solde en attente (débloqué mais pas encore disponible)
  double get soldeAttente => compteAttente?.solde ?? 0;

  factory CompteProprietaire.fromJson(Map<String, dynamic> json) {
    return CompteProprietaire(
      id: json['id'],
      actif: json['actif'],
      solde: json['solde']?.toDouble(),
      numero: json['numero'],
      proprietaireId: json['proprietaireId'] ?? json['proprietaire']?['id'],
      compteAttente: json['compteAttente'] != null
          ? CompteAttente.fromJson(json['compteAttente'])
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['proprietaireId'] = proprietaireId;
    if (compteAttente != null) {
      data['compteAttente'] = compteAttente!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    return 'CompteProprietaire(id: $id, numero: $numero, solde: $solde, actif: $actif, compteAttente: $compteAttente)';
  }
}
