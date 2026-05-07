import 'package:asfar/model/compte/compte_proprietaire.dart';
import 'package:asfar/model/compte/demande_retrait.dart';
import 'package:asfar/model/compte/transaction.dart';
import 'package:asfar/service/compte/compte_api_service.dart';
import 'package:asfar/util/function.dart';

/// Repository pour la gestion des comptes propriétaires
///
/// Architecture online-first (pas de cache local car données sensibles)
/// Toutes les opérations passent par l'API serveur
class CompteRepository {
  final CompteApiService _apiService = CompteApiService();

  /// Récupère le compte du propriétaire connecté
  Future<CompteProprietaire> getCompte() async {
    try {
      final compte = await _apiService.getCompteProprietaire();
      deboger(['[CompteRepository] Compte récupéré: ${compte.numero}']);
      return compte;
    } catch (e) {
      deboger(['[CompteRepository] Erreur récupération compte: $e']);
      rethrow;
    }
  }

  /// Récupère l'historique des transactions
  Future<List<Transaction>> getTransactions({
    DateTime? dateDebut,
    DateTime? dateFin,
    int? limit,
    int? offset,
  }) async {
    try {
      final transactions = await _apiService.getTransactions(
        dateDebut: dateDebut,
        dateFin: dateFin,
        limit: limit,
        offset: offset,
      );
      deboger(['[CompteRepository] Transactions récupérées: ${transactions.length}']);
      return transactions;
    } catch (e) {
      deboger(['[CompteRepository] Erreur récupération transactions: $e']);
      rethrow;
    }
  }

  /// Crée une demande de retrait
  Future<DemandeRetrait> createDemandeRetrait(double montant) async {
    try {
      final demande = await _apiService.createDemandeRetrait(montant);
      deboger(['[CompteRepository] Demande retrait créée: ${demande.id}']);
      return demande;
    } catch (e) {
      deboger(['[CompteRepository] Erreur création demande retrait: $e']);
      rethrow;
    }
  }

  /// Récupère les demandes de retrait
  Future<List<DemandeRetrait>> getDemandesRetrait() async {
    try {
      final demandes = await _apiService.getDemandesRetrait();
      deboger(['[CompteRepository] Demandes retrait récupérées: ${demandes.length}']);
      return demandes;
    } catch (e) {
      deboger(['[CompteRepository] Erreur récupération demandes retrait: $e']);
      rethrow;
    }
  }
}
