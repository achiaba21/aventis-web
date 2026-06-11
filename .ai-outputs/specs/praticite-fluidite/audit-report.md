# 🔍 Rapport d'Audit : Praticité & Fluidité (PRA-01..05 + PERF-01..05)

> Périmètre : 50 fichiers modifiés/créés par la feature `praticite-fluidite`.
> Date : 2026-06-10. Conformité architecturale : CONFORME (après correction
> de l'écart « état pagination ReservationBloc »).

## 📊 Scores

| Dimension       | Avant | Après | Problèmes restants | Statut |
| --------------- | ----- | ----- | ------------------ | ------ |
| Complexité      | 90    | 90    | ⚠️1                | ✅     |
| Lisibilité      | 90    | 100   | —                  | ✅     |
| DRY             | 90    | 90    | ⚠️1                | ✅     |
| Documentation   | 100   | 100   | —                  | ✅     |
| SOLID           | 95    | 95    | ℹ️1                | ✅     |
| Dette technique | 95    | 95    | ℹ️1                | ✅     |
| **GLOBAL**      | 93    | **95** |                   | **✅ VALIDÉ** |

## Vérifications exécutées

- `flutter test` : **293 tests verts** (276 existants + 17 nouveaux PRA-05)
- `flutter analyze` : **0 erreur** (warnings restants tous préexistants)
- Greps de garde-fous du contrat : `_extractBody*` privés = 0, `Image.network`
  hors DomainImage = 0, `formatMontant` = 0, `lib/repository/` supprimé

## 🔧 Correction appliquée pendant l'audit

### Lisibilité — magic number `500` (seuil de scroll)
**Fichier :** `lib/screen/client/locataire/home/home_screen.dart`
**Avant :** `notification.metrics.extentAfter < 500`
**Après :** constante nommée documentée `_loadMoreThresholdPx = 500`.
Re-testé : analyze 0 erreur, suite complète verte.

## ⚠️ Problèmes Majeurs (acceptés, non bloquants)

1. **Complexité** — `AppartementBloc._onLoadMoreAppartements` ~35 lignes (> 30).
   Linéaire (gardes → fetch → fusion → emit), chaque étape commentée ;
   l'extraction en helpers nuirait à la lecture du flux. ACCEPTÉ.
2. **DRY** — les handlers LoadMore d'AppartementBloc et ReservationBloc
   partagent la même structure avec des variations réelles (garde de source,
   clé de dédoublonnage id vs référence, repository). Factoriser maintenant
   serait une abstraction prématurée sur 2 occurrences. ACCEPTÉ — à factoriser
   si un 3ᵉ bloc pagine un jour.

## ℹ️ Améliorations Suggérées (non bloquantes)

1. **SOLID (D)** — les repositories instancient encore leurs services en
   interne (testés via mock HTTP, pas via mock service). À ouvrir si un test
   l'exige (PRA-04 suite).
2. **Dette** — `appartement_repository_test.dart` dépend de l'ordre des tests
   (versioning mémoïsé sur singleton) — contrainte documentée en tête de
   fichier.
3. Constat du sous-agent test (préexistant, hors périmètre) :
   `mapResponseAuto` ne déballe pas le wrapper `{body}` pour les endpoints
   passés à `getMapped` — comportement historique documenté dans
   `dio_request_test.dart`, à unifier un jour avec `tryExtractBodyList`.

## Verdict

```
╔══════════════════════════════════════════════════════════════╗
║  ✅ VALIDÉ                                                    ║
╠══════════════════════════════════════════════════════════════╣
║  Score Final : 95/100 (seuil : 60)                           ║
║  Problèmes critiques : 0 · Correction d'audit : 1 appliquée  ║
║  Tests : 293/293 verts · Analyze : 0 erreur                  ║
║  → Passage à la documentation                                ║
╚══════════════════════════════════════════════════════════════╝
```
