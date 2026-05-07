abstract class CompteEvent {}

/// Charge le compte et les transactions récentes
class LoadCompte extends CompteEvent {}

/// Rafraîchit les données du compte
class RefreshCompte extends CompteEvent {}

/// Charge les transactions avec filtres optionnels
class LoadTransactions extends CompteEvent {
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final int? limit;
  final int? offset;

  LoadTransactions({
    this.dateDebut,
    this.dateFin,
    this.limit,
    this.offset,
  });
}

/// Demande un retrait du solde disponible
class DemanderRetrait extends CompteEvent {
  final double montant;

  DemanderRetrait({required this.montant});
}

/// Charge les demandes de retrait
class LoadDemandesRetrait extends CompteEvent {}

/// Réinitialise l'état du bloc (déconnexion)
class ResetCompteState extends CompteEvent {}
