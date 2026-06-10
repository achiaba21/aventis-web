# PRA-03 — Fusionner les formatters de montants dupliqués

> **Axe :** Praticité · **Sévérité :** 🟡 Moyenne · **Effort :** ~3h

## Problème

Deux implémentations concurrentes du formatage des montants FCFA coexistent et sont
utilisées indifféremment selon les écrans :

- `lib/util/formate.dart` (342 lignes) — `formatMontant()`, `formatMontantCompact()`,
  `formatMontantCompactFCFA()` (~ligne 320)
- `lib/util/fcfa_formatter.dart` (75 lignes) — `FcfaFormatter.full()`, `FcfaFormatter.compact()` (~ligne 54)

Même logique, deux sources de vérité : un changement de format (espace insécable,
arrondi, suffixe « k »/« M ») doit être fait deux fois, et les écrans peuvent afficher
des montants formatés différemment.

## Impact

- Incohérences visuelles possibles entre écrans (proprio vs démarcheur)
- Confusion au moment d'écrire un nouvel écran : lequel utiliser ?

## Marche à suivre

1. **Choisir le canonique** : `FcfaFormatter` (classe dédiée, plus proche de la règle
   projet « helpers dans fichiers dédiés »).
2. **Comparer les sorties** des deux implémentations sur un jeu de valeurs
   (0, 999, 1 500, 25 000, 1 250 000, montants négatifs) et aligner `FcfaFormatter`
   sur le comportement attendu s'il diverge.
3. **Écrire les tests** `test/util/fcfa_formatter_test.dart` figeant ce comportement.
4. **Migrer les usages** :
   ```bash
   grep -rln "formatMontantCompactFCFA\|formatMontantCompact\|formatMontant(" lib/
   ```
   Remplacer écran par écran par `FcfaFormatter.full()` / `.compact()`.
5. **Déprécier dans `formate.dart`** : annoter les fonctions montants `@Deprecated(...)`
   le temps de la migration, puis les supprimer une fois `grep` vide.
   `formate.dart` ne garde que le formatage de dates.
6. **(Optionnel, plus tard)** Regrouper sous `lib/util/formatters/`
   (`amount_formatter.dart`, `date_formatter.dart`) — uniquement si un chantier touche
   déjà ces fichiers, pas de refactoring opportuniste.

## Validation

- [ ] Une seule implémentation de formatage de montants dans `lib/`
- [ ] Tests formatter verts
- [ ] Vérification visuelle des écrans à montants (compta, KPI, cartes annonces)
