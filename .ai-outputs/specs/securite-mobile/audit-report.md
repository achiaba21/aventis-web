# 🔍 Rapport d'Audit : Sécurisation de l'application mobile

> Périmètre : fichiers créés/modifiés par la feature `securite-mobile`
> (voir architecture.md du même dossier). Date : 2026-06-10.

## 📊 Scores

| Dimension       | Score      | Problèmes   | Statut |
| --------------- | ---------- | ----------- | ------ |
| Complexité      | 90/100     | ⚠️1         | ✅     |
| Lisibilité      | 95/100     | ℹ️1         | ✅     |
| DRY             | 95/100     | ℹ️1         | ✅     |
| Documentation   | 100/100    | —           | ✅     |
| SOLID           | 95/100     | ℹ️1         | ✅     |
| Dette technique | 95/100     | ℹ️1         | ✅     |
| **GLOBAL**      | **95/100** |             | **✅ VALIDÉ** |

## Vérifications exécutées

- `flutter test` : **252 tests verts** (dont 6 nouveaux `token_validator_test.dart`)
- `flutter analyze` : **0 erreur** (warnings restants tous préexistants à la feature)
- Greps de contrôle du contrat : clé Stadia = 0, `http://`/`ws://` en dur = 0,
  logs token/PII/secretKey = 0, `local_store.dart` supprimé

## ⚠️ Problèmes Majeurs

### Complexité — `StorageService.init()` ~44 lignes (> seuil 30)

**Fichier :** `lib/service/storage/storage_service.dart:68`
**Constat :** la fonction ouvre 9 boxes séquentiellement ; l'ajout du cipher et de
la purge du jeton legacy l'a allongée de ~6 lignes.
**Mesure :** 44 lignes vs seuil 30.
**Décision :** ACCEPTÉ SANS CORRECTION — la longueur vient de la structure
préexistante (9 ouvertures de boxes, une par ligne, déjà présentes avant la feature).
La règle projet interdit le refactoring opportuniste de l'existant ; la complexité
*ajoutée* par la feature est de 1 niveau (try/catch dans `_openBoxSafely`, extrait
en helper dédié précisément pour ne pas alourdir `init()`).

## ℹ️ Améliorations Suggérées (non bloquantes)

1. **Lisibilité** — `authentication_service.dart:103` : le timeout `Duration(seconds: 3)`
   de `revokeToken()` pourrait être une constante nommée (`_revokeTimeout`).
2. **DRY** — `storage_service.dart:85-94` : les 9 appels `_openBoxSafely` pourraient
   être pilotés par une liste de noms (bloqué par les champs `late Box` individuels —
   refactoring de l'existant, hors périmètre).
3. **SOLID (D)** — accès direct aux singletons (`SecureStorageService.instance`) :
   conforme à la convention du projet (pas de framework DI) ; à revisiter si le
   chantier PRA-04 (GetIt) est lancé.
4. **Dette** — `revokeToken()` avale toutes les erreurs (`catch (_)`) : comportement
   *voulu et documenté* (révocation best-effort, RM7) — signalé pour traçabilité,
   pas une anomalie.

## Verdict

```
╔══════════════════════════════════════════════════════════════╗
║  ✅ VALIDÉ                                                    ║
╠══════════════════════════════════════════════════════════════╣
║  Score Final : 95/100 (seuil : 60)                           ║
║  Problèmes critiques : 0                                     ║
║  Tests : 252/252 verts · Analyze : 0 erreur                  ║
║  → Passage à la documentation                                ║
╚══════════════════════════════════════════════════════════════╝
```
