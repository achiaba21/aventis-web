import 'dart:convert';

import 'package:asfar/model/residence/appart.dart';
import 'package:asfar/service/storage/storage_service.dart';
import 'package:asfar/util/function.dart';

/// Persistance Hive du brouillon d'appartement en cours d'édition dans le wizard.
///
/// V1 : un seul slot de brouillon (clé fixe `current`). Si un nouveau brouillon
/// est sauvegardé, il remplace le précédent. À la publication finale, le draft
/// est effacé via [clear].
///
/// Sérialise via `Appartement.toJson()` / `Appartement.fromJson()` — pas de
/// TypeAdapter Hive (cf. PLAN_CACHE_HIVE_PROPRIO.md, phase non terminée).
class AppartementDraftStorage {
  static const String _slotKey = 'current';

  static AppartementDraftStorage? _instance;

  /// Singleton instance.
  static AppartementDraftStorage get instance {
    _instance ??= AppartementDraftStorage._internal();
    return _instance!;
  }

  AppartementDraftStorage._internal();

  /// Sauvegarde (ou remplace) le brouillon courant.
  Future<void> save(Appartement draft) async {
    try {
      final json = jsonEncode(draft.toJson());
      await StorageService.instance.draftBox.put(_slotKey, json);
    } catch (e) {
      deboger('AppartementDraftStorage.save erreur: $e');
    }
  }

  /// Charge le brouillon courant, ou `null` si aucun.
  Appartement? load() {
    try {
      final raw = StorageService.instance.draftBox.get(_slotKey) as String?;
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return Appartement.fromJson(map);
    } catch (e) {
      deboger('AppartementDraftStorage.load erreur: $e');
      return null;
    }
  }

  /// Indique si un brouillon est présent.
  bool hasDraft() {
    return StorageService.instance.draftBox.containsKey(_slotKey);
  }

  /// Efface le brouillon courant.
  Future<void> clear() async {
    await StorageService.instance.draftBox.delete(_slotKey);
  }
}
