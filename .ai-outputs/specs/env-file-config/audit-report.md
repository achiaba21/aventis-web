# 🔍 Rapport d'Audit : env-file-config

> Périmètre : migration des variables `--dart-define` vers un fichier `.env`
> (flutter_dotenv 5.2.1). 8 fichiers (3 créés, 5 modifiés).
> Date : 2026-06-11. Mode : Feature Light.

## 📊 Scores

| Dimension       | Avant | Après | Problèmes | Statut |
| --------------- | ----- | ----- | --------- | ------ |
| Complexité      | 100   | 100   | —         | ✅     |
| Lisibilité      | 100   | 100   | —         | ✅     |
| DRY             | 100   | 100   | —         | ✅     |
| Documentation   | 100   | 100   | —         | ✅     |
| SOLID           | 95    | 95    | ℹ️1       | ✅     |
| Dette technique | 80    | 95    | ℹ️1       | ✅     |
| **GLOBAL**      | 96    | **98** |          | **✅ VALIDÉ** |

## Vérifications exécutées

- `flutter test` : **293 tests verts** — sans `dotenv.load`, les tests retombent
  bien sur les défauts (garde `dotenv.isInitialized` dans `envOr`)
- `flutter analyze` : **0 erreur, 46 issues** — identique à avant la feature
  (toutes préexistantes)
- Greps de garde-fous : plus aucun `fromEnvironment` dans `lib/` ;
  `.env` bien gitignoré, `.env.example` versionné

## 🔧 Correction appliquée pendant l'audit

### Dette technique — catch vide (🚨 critique → résolu)
**Fichier :** `lib/main.dart`
**Avant :** `try { await dotenv.load(...) } catch (_) { /* commentaire */ }` —
catch vide, masquerait aussi des erreurs inattendues.
**Après :** `await dotenv.load(fileName: '.env', isOptional: true)` — paramètre
dédié du package (vérifié présent en 5.2.1), même sémantique option A sans
avaler d'exception. Re-testé : 293 verts, analyze inchangé.

## ℹ️ Améliorations Suggérées (non bloquantes)

1. **SOLID** — la config reste des `final` top-level (état global), cohérent
   avec l'existant du projet (`domain`/`wsDomain`). À revisiter seulement si la
   config devient injectable (suite PRA-04).
2. **Dette** — `.env` étant déclaré comme asset, il doit exister au moment du
   build : sur un clone frais, `flutter build` échoue tant que
   `cp .env.example .env` n'a pas été fait (message d'asset manquant explicite).
   Contrainte documentée en tête de `.env.example`. L'option A (jamais bloquant)
   reste garantie au runtime.

## Verdict

```
╔══════════════════════════════════════════════════════════════╗
║  ✅ VALIDÉ                                                    ║
╠══════════════════════════════════════════════════════════════╣
║  Score Final : 98/100 (seuil : 60)                           ║
║  Problèmes critiques : 0 · Correction d'audit : 1 appliquée  ║
║  Tests : 293/293 verts · Analyze : 0 erreur                  ║
║  → Passage à la documentation                                ║
╚══════════════════════════════════════════════════════════════╝
```
