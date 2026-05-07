import 'package:asfar/model/comptabilite/appartement_info.dart';
import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/model/comptabilite/frequence_charge.dart';
import 'package:asfar/model/comptabilite/type_charge.dart';
import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/comptabilite/comptabilite_api_service.dart';
import 'package:asfar/service/repository/charge_repository.dart';
import 'package:asfar/util/function.dart';

/// Manager pour la gestion des charges (API + Cache local)
///
/// Architecture online-first avec fallback offline:
/// - Priorité: API serveur
/// - Fallback: Cache Hive local
/// - Synchronisation: mise à jour du cache après succès API
///
/// Note: Utilise ChargeRepository pour le stockage Hive local.
///
/// Depuis BACKEND-FLAT-APPART, ce manager n'a plus connaissance de
/// Résidence. Le filtre `residenceId` n'a plus d'effet local (sera ignoré
/// en fallback offline).
class ChargeDataManager {
  final ComptabiliteApiService _apiService = ComptabiliteApiService();
  final ChargeRepository _localRepository = ChargeRepository();

  // Données injectées depuis AppartementBloc (pour résoudre les infos
  // d'appartement en mode offline lors de la création).
  List<Appartement> _apparts = [];

  /// Injecter les appartements (pour récupérer les infos en mode offline).
  void setAppartements(List<Appartement> appartements) {
    _apparts = appartements;
  }

  /// Récupère toutes les charges avec filtres optionnels.
  ///
  /// `residenceId` est conservé pour compatibilité API serveur mais n'est
  /// plus utilisé en fallback local (le modèle plat ne référence plus de
  /// résidence côté client).
  Future<List<Charge>> getCharges({
    int? residenceId,
    int? appartementId,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    try {
      final charges = await _apiService.getAllCharges(
        residenceId: residenceId,
        appartementId: appartementId,
        dateDebut: dateDebut,
        dateFin: dateFin,
      );

      await _syncLocalCharges(charges);

      deboger(['[ChargeDataManager] Charges récupérées depuis API: ${charges.length}']);
      return charges;
    } catch (e) {
      deboger(['[ChargeDataManager] Erreur API, fallback local: $e']);
      return _localRepository.getCharges(
        appartementIds: null, // pas de filtre par résidence en local
        dateDebut: dateDebut,
        dateFin: dateFin,
      );
    }
  }

  /// Crée une nouvelle charge
  Future<Charge> createCharge({
    required int appartementId,
    required TypeCharge typeCharge,
    String? libelle,
    required double montant,
    required FrequenceCharge frequence,
    DateTime? dateDebut,
    DateTime? dateEcheance,
    bool estRecurrent = false,
    String? notes,
  }) async {
    final appartInfo = _findAppartementInfo(appartementId);

    final charge = Charge.create(
      appartementId: appartementId,
      appartementNom: appartInfo.appartementNom,
      residenceId: appartInfo.residenceId,
      residenceNom: appartInfo.residenceNom,
      typeCharge: typeCharge,
      libelle: libelle,
      montant: montant,
      frequence: frequence,
      dateDebut: dateDebut,
      dateEcheance: dateEcheance,
      estRecurrent: estRecurrent,
      notes: notes,
    );

    try {
      final createdCharge = await _apiService.createCharge(charge);
      await _localRepository.addCharge(createdCharge);
      deboger(['[ChargeDataManager] Charge créée via API: ${createdCharge.id}']);
      return createdCharge;
    } catch (e) {
      deboger(['[ChargeDataManager] Erreur API création, sauvegarde locale: $e']);
      final localCharge = await _localRepository.addCharge(charge);
      return localCharge;
    }
  }

  /// Met à jour une charge existante
  Future<Charge> updateCharge(Charge charge) async {
    try {
      final updatedCharge = await _apiService.updateCharge(charge);
      await _localRepository.updateCharge(updatedCharge);
      deboger(['[ChargeDataManager] Charge mise à jour via API: ${charge.id}']);
      return updatedCharge;
    } catch (e) {
      deboger(['[ChargeDataManager] Erreur API update, sauvegarde locale: $e']);
      await _localRepository.updateCharge(charge);
      return charge;
    }
  }

  /// Supprime une charge
  Future<void> deleteCharge(int chargeId) async {
    try {
      await _apiService.deleteCharge(chargeId);
      deboger(['[ChargeDataManager] Charge supprimée via API: $chargeId']);
    } catch (e) {
      deboger(['[ChargeDataManager] Erreur API suppression: $e']);
    }
    await _localRepository.deleteCharge(chargeId);
  }

  /// Marque une charge comme payée
  Future<Charge?> markAsPaid(int chargeId, {DateTime? datePaiement}) async {
    try {
      final updatedCharge = await _apiService.markChargeAsPaid(
        chargeId,
        datePaiement: datePaiement,
      );
      await _localRepository.markAsPaid(chargeId, datePaiement: datePaiement);
      deboger(['[ChargeDataManager] Charge marquée payée via API: $chargeId']);
      return updatedCharge;
    } catch (e) {
      deboger(['[ChargeDataManager] Erreur API markAsPaid, sauvegarde locale: $e']);
      await _localRepository.markAsPaid(chargeId, datePaiement: datePaiement);
      return _localRepository.getChargeById(chargeId);
    }
  }

  /// Vide le cache local (déconnexion)
  Future<void> clearCache() async {
    await _localRepository.clearAllCharges();
    _apparts = [];
    deboger(['[ChargeDataManager] Cache vidé']);
  }

  // ==================== Méthodes privées ====================

  Future<void> _syncLocalCharges(List<Charge> serverCharges) async {
    try {
      await _localRepository.clearAllCharges();
      for (final charge in serverCharges) {
        await _localRepository.addCharge(charge);
      }
      deboger(['[ChargeDataManager] Cache local synchronisé: ${serverCharges.length} charges']);
    } catch (e) {
      deboger(['[ChargeDataManager] Erreur sync cache: $e']);
    }
  }

  /// Cherche les infos d'un appartement parmi ceux injectés.
  ///
  /// Le champ `residenceNom` est dérivé de l'adresse (commune ou nom),
  /// `residenceId` est laissé null (le modèle plat n'a plus d'ID résidence
  /// côté client). Le backend, lui, conserve sa résidence virtuelle via le
  /// mapper.
  AppartementInfo _findAppartementInfo(int appartementId) {
    try {
      final appart = _apparts.firstWhere((a) => a.id == appartementId);
      final addr = appart.address;
      final residenceNom = addr?.commune?.nom ?? addr?.nom;
      return AppartementInfo(
        residenceId: null,
        residenceNom: residenceNom,
        appartementNom: appart.titre ?? appart.numero,
      );
    } catch (_) {
      deboger(['[ChargeDataManager] Appartement non trouvé: $appartementId']);
      return const AppartementInfo.empty();
    }
  }
}
