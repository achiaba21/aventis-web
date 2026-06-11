# 📋 Spécification Métier : Praticité & Fluidité (axes PRA + PERF de l'audit)

> Statut : ✅ validée par l'utilisateur le 2026-06-10
> Référence détaillée : fiches `.ai-outputs/audit/PRA-01..05` et `PERF-01..05`

### 1. Contexte

L'axe sécurité de l'audit de juin 2026 est livré. Restent la **praticité** (doublons,
logique répétée 18 fois, quasi-absence de filet de tests) et la **fluidité** (images
re-téléchargées en permanence, listes chargées entières, rebuilds excessifs, mémoire
non bornée). Pas encore d'utilisateurs réels : le moment d'assainir avant la croissance.

### 2. Objectif

App plus rapide et économe pour l'utilisateur (images instantanées, listes fluides,
données fraîches, stabilité longues sessions) et plus sûre à faire évoluer pour
l'équipe (une seule façon de faire par sujet, tests sur la couche données).

### 3. Acteurs

- **Tous les utilisateurs** : moins d'attente, moins de data, données plus fraîches.
- **Équipe de dev** : conventions uniques, régressions détectées par les tests.

### 4. Règles Métier

| ID | Règle | Description |
|---|---|---|
| RM1 | Images mémorisées | Une image déjà vue ne se retélécharge pas ; indicateur visuel discret pendant le premier chargement (PERF-01). |
| RM2 | Listes progressives | Annonces/réservations chargées par pages au scroll. Sans backend paginé : comportement actuel préservé à l'identique (PERF-02, prérequis backend documenté). |
| RM3 | Réactions ciblées | Un like ne reconstruit que la carte concernée (PERF-03). |
| RM4 | Données fraîches | TTL par domaine (1 h annonces, 15 min réservations) avec rafraîchissement auto en arrière-plan ; cache incompatible purgé sans crash (PERF-04). |
| RM5 | Mémoire bornée | Listes en mémoire plafonnées ; l'historique au-delà se recharge depuis le cache disque (PERF-05). |
| RM6 | Une seule façon de faire | Un emplacement repositories (PRA-01), une extraction des réponses serveur (PRA-02), un formateur de montants (PRA-03), une manière d'obtenir un service (PRA-04, progressif). |
| RM7 | Filet de tests | Mapping réponses, client HTTP, 2 services et 2 repositories critiques couverts par tests automatisés (PRA-05). |
| RM8 | Iso-comportement | Aucun changement fonctionnel visible hors gains de fluidité. |

### 5. Cas d'Usage Principal

**Préconditions :** utilisateur connecté, nouvelle version installée.

1. Ouverture du feed : images avec effet de chargement bref, puis instantanées à chaque retour.
2. Scroll : liste complétée par pages, sans à-coup.
3. Like : seul le cœur de la carte concernée réagit.
4. Retour le lendemain : données périmées rafraîchies seules.
5. Navigation 2 h : aucune dégradation ni fermeture inopinée.

**Postconditions :** data réduite, latence perçue en forte baisse, code uniformisé et testé.

### 6. Cas Alternatifs

| Cas | Condition | Comportement |
|---|---|---|
| CA1 | Backend sans pagination | Listes chargées comme aujourd'hui, sans erreur ni doublon. |
| CA2 | Hors ligne | Images vues + cache local affichés ; rafraîchissement au retour du réseau (mécanisme existant). |
| CA3 | Cache incompatible | Purge silencieuse + rechargement serveur, jamais de crash. |

### 7. Gestion des Erreurs

| Erreur | Condition | Comportement |
|---|---|---|
| E1 | Image introuvable | Visuel de remplacement existant, pas de re-tentative en boucle. |
| E2 | Page suivante en échec | Éléments déjà affichés conservés + réessai possible. |

### 8. Contraintes

- **Backend (prérequis documenté, hors périmètre)** : pagination `page/size` sur annonces/réservations.
- **Règle projet** : GetIt progressif (socle + blocs touchés uniquement) ; pas de refactoring hors fiches.
- **Qualité** : 252 tests existants verts + 6 nouvelles cibles PRA-05.

### 9. Critères d'Acceptation

- [ ] Scroll aller-retour feed : aucune image re-téléchargée.
- [ ] Un like ne reconstruit que la carte concernée.
- [ ] Cache vieilli → refresh auto ; version incrémentée → purge propre sans crash.
- [ ] Session longue : mémoire stable (plafonds actifs).
- [ ] Backend paginé : chargement progressif ; sinon : comportement identique.
- [ ] Un seul dossier repositories, zéro `_extractBodyMap` dupliqué, un seul formateur de montants, montants inchangés.
- [ ] `flutter test` vert avec les 6 nouvelles suites couche données.

### 10. Hors Périmètre

- Implémentation backend de la pagination (prérequis).
- Migration GetIt des blocs non touchés.
- Redimensionnement images côté serveur (phase 2 PERF-01).
- Axe sécurité (livré), tout refactoring hors des 10 fiches.

### Décisions de cadrage (réponses utilisateur, 2026-06-10)

- Périmètre : **les 10 fiches**, livraison en une fois.
- PERF-02 : **préparé côté mobile**, backend = prérequis.
- PRA-04 : migration GetIt **progressive**.
- PRA-05 : **les 6 cibles** de la fiche.
