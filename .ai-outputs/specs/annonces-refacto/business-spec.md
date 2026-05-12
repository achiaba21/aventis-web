# 📋 Spécification Métier : Refacto système Annonces

> **Feature :** `annonces-refacto`
> **Date :** 2026-05-12
> **Type :** Refactoring transversal — sans changement fonctionnel utilisateur visible
> **Statut :** ✅ Validée par utilisateur

---

## 1. Contexte

Audit du système Annonces (Appartements) a révélé 10 problèmes : 1 bug critique UX (note aléatoire), 1 hack stabilité (delayed 300ms), 8 points de dette technique / architecture. Sans rebâtir tout, on cible 6 améliorations qui éliminent les risques immédiats et préparent les chantiers futurs.

## 2. Objectif

Stabiliser et nettoyer la base technique du système Annonces **sans changement fonctionnel utilisateur visible**, en préservant la rétro-compatibilité des 40 fichiers UI consommateurs.

## 3. Acteurs concernés

Aucun changement direct pour les acteurs (locataire / proprio / démarcheur). Le refacto est invisible côté UI sauf pour le bug `note` qui disparaît visuellement.

## 4. Périmètre V1 — 6 points

| # | Action | Bénéfice |
|---|--------|----------|
| **RM1** | Note `Random()` retirée → champ `note: double?` (backend ou moyenne commentaires) | Fix UX critique : la note d'un appart ne change plus à chaque rebuild |
| **RM2** | `Future.delayed(300ms)` retiré du BLoC CRUD → state avec `transientMessage` | Code stable, plus de delay arbitraire fragile |
| **RM3** | 3 `*Loaded` distincts mergés en 1 `AppartementLoaded(source: ListSource)` | Simplification : 9 states → 4 states |
| **RM4** | Filtre extrait dans `AppartementFilterCubit` séparé | Pattern aligné avec `ComptabiliteFilterCubit`, BLoC moins surchargé |
| **RM5** | Locataire passe par `AppartementRepository` (cache-first) | Mode offline + UX plus fluide pour le feed découverte |
| **RM8** | Tests sur `AppartementBackendMapper` (round-trip JSON) | Filet de sécurité sur la couche legacy résidence |

## 5. Hors scope V1 (documentation seulement)

| # | Sujet | Pourquoi documenté seulement |
|---|-------|------------------------------|
| RM6 | Règle de visibilité (`brouillon` / `isVisible` / `AppartementStatus`) | Décision métier requise + besoin clarification backend |
| RM7 | Pagination cursor-based | Nécessite support backend (Spring Boot) |

→ Documentation centralisée dans `BACKEND_NOTES_ANNONCE.md` à la racine du projet.

## 6. Contraintes critiques

- **Rétro-compatibilité absolue** : les 40 fichiers UI consommant `AppartementBloc` ne doivent pas casser. Ajouter des alias deprecated si besoin avant de retirer.
- **`AppartementWizardBloc` non touché** : indépendant de ce refacto.
- **Pattern « keep last known data »** : préservé partout (état conserve la dernière liste connue).
- **`AppartementBackendMapper` conservé** : couche legacy résidence reste en place (sa suppression dépend de BACKEND-FLAT-APPART, point distinct).

## 7. Critères d'acceptation

- [ ] `Random()` retiré du modèle `Appartement`, la note vient d'un champ stable
- [ ] Aucun `Future.delayed` dans `AppartementBloc`
- [ ] Un seul `AppartementLoaded` exposé, avec champ `source` pour différencier les contextes
- [ ] `AppartementFilterCubit` créé et utilisé par les écrans qui filtrent (search, etc.)
- [ ] Locataire home/search/favorite passent par le repository (cache-first)
- [ ] Tests `AppartementBackendMapper` : ≥ 6 tests verts (create, update, fromBackend, extractResidenceId, sans/avec address, avec/sans backendResidenceId)
- [ ] `BACKEND_NOTES_ANNONCE.md` créé avec les 2 demandes backend (visibilité + pagination)
- [ ] `flutter analyze` clean sur tous les fichiers touchés
- [ ] **Aucune régression UI** : tous les écrans existants continuent de fonctionner sans modification de leur code

## 8. Hors périmètre V1 (autre)

- Refacto du wizard (`AppartementWizardBloc`)
- Suppression de `AppartementBackendMapper` (dépend BACKEND-FLAT-APPART)
- Refacto de l'extension `AppartementDisplay`
- Suppression des champs redondants (`regles` vs `rules`)
