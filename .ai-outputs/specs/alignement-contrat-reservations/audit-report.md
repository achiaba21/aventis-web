# 🔍 Rapport d'Audit : alignement-contrat-reservations

> Périmètre : 18 fichiers modifiés (15 lib + 3 tests) — alignement sur le
> contrat réservations backend du 2026-06-11.
> Date : 2026-06-11. Mode : Feature Light.

## 📊 Scores

| Dimension       | Score | Problèmes | Statut |
| --------------- | ----- | --------- | ------ |
| Complexité      | 100   | —         | ✅     |
| Lisibilité      | 100   | —         | ✅     |
| DRY             | 100   | —         | ✅     |
| Documentation   | 100   | —         | ✅     |
| SOLID           | 100   | —         | ✅     |
| Dette technique | 90    | ℹ️2       | ✅     |
| **GLOBAL**      | **98** |          | **✅ VALIDÉ** |

## Vérifications exécutées

- `flutter analyze` : 0 erreur, 0 warning nouveau (46 préexistantes inchangées)
- `flutter test` : **295/295 verts** (3 cas de tests retirés avec les statuts,
  3 convertis vers les statuts de remplacement, 2 réécrits pour la nouvelle
  règle d'édition manuelle)
- Garde-fous : plus aucune occurrence `ReservationStatus.refusee/terminee`
  ni chaîne `REFUSEE`/`TERMINEE` du domaine réservation dans lib/ et test/
  (`StatutPartenariat.refusee` — domaine partenariat — intentionnellement
  préservé) ; libellé PDF P&L corrigé (PAYER + FINALISER)

## Changements livrés

1. **Édition résa manuelle** (`reservation_actions_resolver.dart`) — `edit`
   offert en `enAttente`/`confirmee`/`finalisee` (les manuelles naissent en
   FINALISER côté backend) ; verrou « argent encaissé » et commentaire RM4
   obsolète retirés ; raison documentée sur le case `finalisee`.
2. **Clé `proprio`** (`appart.dart`) — `json['proprio'] ?? json['proprietaire']`,
   commentaire de contrat daté.
3. **Enum réduit à 5 statuts** — adaptations sémantiques systématiques :
   `terminee` → comportement de `finalisee` (revenus, KPI, badges, filtres,
   timeline) ; `refusee` → comportement d'`annulee` (taux d'acceptation,
   timeline démarcheur, exclusions calendrier) ; chip proprio « Refusées »
   renommée « Annulées ».

## ℹ️ Améliorations Suggérées (non bloquantes)

1. **Dette** — `ReservationTimelineEventType.refused` et `.terminated` sont
   désormais inatteignables (plus aucun statut ne les produit) : valeurs
   d'enum + libellés morts à purger lors d'un prochain passage sur la timeline.
2. **Question métier ouverte** — l'action proprio « Refuser » (plateforme,
   `enAttente`) existe toujours : vérifier avec le backend quel statut résulte
   du refus (probablement `ANULLE`) et si le motif est porté.

## Verdict

```
╔══════════════════════════════════════════════════════════════╗
║  ✅ VALIDÉ — Score : 98/100 (seuil : 60)                     ║
║  Tests : 295/295 verts · Analyze : 0 erreur                  ║
╚══════════════════════════════════════════════════════════════╝
```
