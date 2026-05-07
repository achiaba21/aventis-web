import 'package:asfar/model/comptabilite/charge.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Repository pour les charges - gère le stockage local via Hive
///
/// Les charges sont uniquement stockées localement (pas de sync API pour l'instant)
/// Utilise StorageService pour la persistance
class ChargeRepository {
  // Singleton
  static final ChargeRepository _instance = ChargeRepository._internal();
  factory ChargeRepository() => _instance;
  ChargeRepository._internal();

  // Référence au StorageService
  final StorageService _storage = StorageService.instance;

  /// Récupère toutes les charges
  List<Charge> getAllCharges() {
    try {
      final chargesData = _storage.getCharges();
      return chargesData.map((json) => Charge.fromJson(json)).toList();
    } catch (e) {
      deboger(['[ChargeRepository] Erreur getAllCharges: $e']);
      return [];
    }
  }

  /// Récupère les charges filtrées par appartement(s) et/ou période
  ///
  /// - appartementId: filtre par un seul appartement
  /// - appartementIds: filtre par plusieurs appartements (pour agrégation résidence)
  /// - Si les deux sont null, retourne toutes les charges
  Future<List<Charge>> getCharges({
    int? appartementId,
    List<int>? appartementIds,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final allCharges = getAllCharges();

    return allCharges.where((charge) {
      // Filtre par appartement unique
      if (appartementId != null && charge.appartementId != appartementId) {
        return false;
      }

      // Filtre par liste d'appartements (pour résidence = somme des appartements)
      if (appartementIds != null && appartementIds.isNotEmpty) {
        if (charge.appartementId == null || !appartementIds.contains(charge.appartementId)) {
          return false;
        }
      }

      // Filtre par période (basé sur dateEcheance ou createdAt)
      if (dateDebut != null || dateFin != null) {
        final chargeDate = charge.dateEcheance ?? charge.createdAt;
        if (chargeDate == null) return true; // Inclure si pas de date

        if (dateDebut != null && chargeDate.isBefore(dateDebut)) {
          return false;
        }
        if (dateFin != null && chargeDate.isAfter(dateFin)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Récupère les charges avec alertes (en retard ou échéance proche)
  Future<List<Charge>> getChargesAvecAlertes() async {
    final allCharges = getAllCharges();
    return allCharges
        .where((c) => c.estEnRetard || c.echeanceProche)
        .toList()
      ..sort((a, b) {
        // Trier par urgence: en retard d'abord, puis par date d'échéance
        if (a.estEnRetard && !b.estEnRetard) return -1;
        if (!a.estEnRetard && b.estEnRetard) return 1;
        if (a.dateEcheance == null) return 1;
        if (b.dateEcheance == null) return -1;
        return a.dateEcheance!.compareTo(b.dateEcheance!);
      });
  }

  /// Ajoute une nouvelle charge
  Future<Charge> addCharge(Charge charge) async {
    try {
      final allCharges = getAllCharges();

      // Générer un nouvel ID
      final lastId = _storage.getChargesLastId();
      final newId = lastId + 1;

      // Mettre à jour la charge avec le nouvel ID
      final newCharge = charge.copyWith(
        id: newId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      allCharges.add(newCharge);

      // Sauvegarder
      await _saveCharges(allCharges);
      await _storage.setChargesLastId(newId);

      deboger(['[ChargeRepository] Charge ajoutée: $newCharge']);
      return newCharge;
    } catch (e) {
      deboger(['[ChargeRepository] Erreur addCharge: $e']);
      rethrow;
    }
  }

  /// Met à jour une charge existante
  Future<void> updateCharge(Charge charge) async {
    try {
      final allCharges = getAllCharges();

      final index = allCharges.indexWhere((c) => c.id == charge.id);
      if (index == -1) {
        throw Exception('Charge non trouvée: ${charge.id}');
      }

      allCharges[index] = charge.copyWith(updatedAt: DateTime.now());

      await _saveCharges(allCharges);
      deboger(['[ChargeRepository] Charge mise à jour: ${charge.id}']);
    } catch (e) {
      deboger(['[ChargeRepository] Erreur updateCharge: $e']);
      rethrow;
    }
  }

  /// Supprime une charge
  Future<void> deleteCharge(int chargeId) async {
    try {
      final allCharges = getAllCharges();
      allCharges.removeWhere((c) => c.id == chargeId);

      await _saveCharges(allCharges);
      deboger(['[ChargeRepository] Charge supprimée: $chargeId']);
    } catch (e) {
      deboger(['[ChargeRepository] Erreur deleteCharge: $e']);
      rethrow;
    }
  }

  /// Marque une charge comme payée
  Future<void> markAsPaid(int chargeId, {DateTime? datePaiement}) async {
    try {
      final allCharges = getAllCharges();

      final index = allCharges.indexWhere((c) => c.id == chargeId);
      if (index == -1) {
        throw Exception('Charge non trouvée: $chargeId');
      }

      allCharges[index] = allCharges[index].copyWith(
        estPaye: true,
        datePaiement: datePaiement ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveCharges(allCharges);
      deboger(['[ChargeRepository] Charge marquée comme payée: $chargeId']);
    } catch (e) {
      deboger(['[ChargeRepository] Erreur markAsPaid: $e']);
      rethrow;
    }
  }

  /// Récupère une charge par son ID
  Charge? getChargeById(int chargeId) {
    final allCharges = getAllCharges();
    try {
      return allCharges.firstWhere((c) => c.id == chargeId);
    } catch (_) {
      return null;
    }
  }

  /// Récupère les charges par appartement
  Future<List<Charge>> getChargesByAppartement(int appartementId) async {
    return getCharges(appartementId: appartementId);
  }

  /// Récupère les charges pour plusieurs appartements (agrégation résidence)
  Future<List<Charge>> getChargesByAppartements(List<int> appartementIds) async {
    return getCharges(appartementIds: appartementIds);
  }

  /// Calcule le total des charges pour un/plusieurs appartement(s) sur une période
  Future<double> getTotalCharges({
    int? appartementId,
    List<int>? appartementIds,
    DateTime? dateDebut,
    DateTime? dateFin,
  }) async {
    final charges = await getCharges(
      appartementId: appartementId,
      appartementIds: appartementIds,
      dateDebut: dateDebut,
      dateFin: dateFin,
    );
    return charges.fold<double>(0.0, (sum, c) => sum + (c.montant ?? 0));
  }

  /// Supprime toutes les charges (pour debug/reset)
  Future<void> clearAllCharges() async {
    await _storage.clearCharges();
    deboger(['[ChargeRepository] Toutes les charges supprimées']);
  }

  /// Sauvegarde les charges dans Hive via StorageService
  Future<void> _saveCharges(List<Charge> charges) async {
    final chargesJson = charges.map((c) => c.toJson()).toList();
    await _storage.saveCharges(chargesJson);
  }
}
