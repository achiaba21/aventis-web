import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Migration one-shot : transfère l'`address` des anciennes "résidences"
/// directement dans les `appartements` puis vide la box résidences.
///
/// IMPORTANT : aucune classe `Residence` n'est importée. Les anciennes
/// données sont lues en JSON brut (`Map<String, dynamic>`) directement
/// depuis Hive via [StorageService].
///
/// Idempotente : un flag `migration_v2_appart_address_done` est posé dans
/// la box `app_settings` après exécution. Tout appel ultérieur est un noop.
class LegacyResidenceMigration {
  static const String _migrationFlagKey = 'migration_v2_appart_address_done';

  static LegacyResidenceMigration? _instance;

  /// Singleton instance.
  static LegacyResidenceMigration get instance {
    _instance ??= LegacyResidenceMigration._internal();
    return _instance!;
  }

  LegacyResidenceMigration._internal();

  /// Exécute la migration si elle n'a pas encore tourné.
  ///
  /// À appeler dans `main()` après `StorageService.instance.init()`.
  Future<void> runIfNeeded() async {
    final storage = StorageService.instance;

    if (storage.getAppSetting<bool>(_migrationFlagKey) == true) {
      deboger('LegacyResidenceMigration: déjà exécutée, skip');
      return;
    }

    try {
      deboger('LegacyResidenceMigration: démarrage');

      final residences = storage.getResidences();
      final appartements = storage.getAppartements();

      // Indexer les résidences par ID pour lookup rapide
      final residenceById = <int, Map<String, dynamic>>{};
      for (final res in residences) {
        final id = res['id'];
        if (id is int) {
          residenceById[id] = res;
        }
      }

      // Fusionner l'address dans chaque appartement orphelin
      var migratedCount = 0;
      var orphanCount = 0;
      final migrated = appartements.map((appart) {
        // Si l'appart a déjà une address → ne pas écraser
        if (appart['address'] != null) {
          return appart;
        }

        final residenceId = appart['residenceId'];
        if (residenceId is int) {
          final parent = residenceById[residenceId];
          if (parent != null && parent['address'] != null) {
            final merged = Map<String, dynamic>.from(appart);
            merged['address'] = parent['address'];
            // Nettoyer les vestiges du legacy
            merged.remove('residenceId');
            merged.remove('residence');
            migratedCount++;
            return merged;
          }
        }

        // Appartement orphelin : address reste null, sera flaggé en UI
        orphanCount++;
        final cleaned = Map<String, dynamic>.from(appart)
          ..remove('residenceId')
          ..remove('residence');
        return cleaned;
      }).toList();

      // Sauvegarder les appartements migrés
      await storage.saveAppartements(migrated);

      // Vider la box résidences (devenue inutile)
      await storage.clearResidences();

      // Poser le flag de migration
      await storage.setAppSetting(_migrationFlagKey, true);

      deboger(
        'LegacyResidenceMigration: terminée — '
        '$migratedCount migrés, $orphanCount orphelins, '
        '${residences.length} résidences supprimées',
      );
    } catch (e) {
      deboger('LegacyResidenceMigration: erreur — $e');
      // Ne pas poser le flag : la prochaine ouverture retentera
    }
  }
}
