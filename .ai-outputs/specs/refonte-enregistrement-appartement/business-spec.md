# 📋 Spécification Métier — Refonte Enregistrement Appartement

**Feature** : `refonte-enregistrement-appartement`
**Date** : 2026-05-03
**Auteur** : Agent Business Analyst
**Statut** : En attente de validation utilisateur

---

## 1. Contexte

L'application Asfar permet aujourd'hui à un propriétaire d'enregistrer ses biens locatifs en 2 temps :
1. Créer une **Résidence** (nom + adresse GPS)
2. Y rattacher un ou plusieurs **Appartements**

Cette structure est techniquement correcte mais **complexe pour l'utilisateur** : un proprio qui n'a qu'un seul bien doit comprendre et créer une "résidence" intermédiaire, ce qui ralentit son onboarding et crée de l'abandon. La plupart des proprios ont 1 à 5 biens distincts à des adresses différentes — la résidence n'apporte aucune valeur perçue.

De plus, la séparation Résidence / Appartement double les écrans, les BLoCs, les formulaires, et complique la maintenance.

## 2. Objectif

**Permettre à un propriétaire d'enregistrer un appartement en quelques secondes, sans aucune notion intermédiaire à comprendre, via un parcours guidé inspiré des meilleurs standards (Airbnb).**

L'adresse devient un attribut direct de l'appartement. La notion de "résidence" disparaît complètement de l'expérience utilisateur (proprio comme locataire).

## 3. Acteurs

| Acteur | Rôle dans la feature |
|--------|----------------------|
| **Propriétaire** | Acteur principal — crée, modifie, supprime ses appartements |
| **Locataire** | Acteur secondaire — voit une liste plate d'appartements (plus de regroupement par résidence) |
| **Démarcheur** | Hors périmètre direct (mais bénéficie indirectement de la simplification du modèle) |

## 4. Règles Métier

### 4.1 Modèle de données
- **R1** : L'entité `Résidence` est **supprimée** du modèle propriétaire
- **R2** : L'**adresse** (GPS lat/lng + texte descriptif) devient un attribut **obligatoire** de l'`Appartement`
- **R3** : Chaque appartement est **indépendant** — pas de regroupement implicite ni explicite
- **R4** : Le **titre** de l'appartement reste **obligatoire** (ex: "Studio Cocody Angré")

### 4.2 Champs obligatoires pour publier
| Champ | Obligatoire publication | Obligatoire brouillon |
|-------|:-:|:-:|
| Titre | ✅ | ✅ |
| Adresse (GPS + texte) | ✅ | ❌ |
| Type de location | ✅ | ❌ |
| Nb chambres / lits / douches | ✅ | ❌ |
| Prix | ✅ | ❌ |
| **Photos (min 3)** | ✅ | ❌ |
| Équipements | ⚠️ recommandé | ❌ |
| Description | ⚠️ recommandé | ❌ |

### 4.3 Brouillon
- **R5** : Auto-save **silencieux** en brouillon à chaque étape franchie (pas de bouton "Enregistrer brouillon" visible)
- **R6** : À la fermeture du formulaire (back, fermeture app), si non publié → l'état est conservé en brouillon local
- **R7** : À la réouverture du formulaire (FAB "+" depuis Mes Appartements), si un brouillon existe → proposer de **reprendre** ou **repartir de zéro**
- **R8** : Le brouillon n'est **jamais envoyé au backend** tant que l'utilisateur ne valide pas la publication finale

### 4.4 Géolocalisation
- **R9** : Au lancement du formulaire, l'app **demande la permission GPS** et tente une **auto-détection** de la position
- **R10** : L'utilisateur peut **ajuster manuellement** la position via une carte interactive (pin déplaçable)
- **R11** : Si la permission est refusée → fallback sur saisie manuelle via map (comportement actuel)
- **R12** : Une **adresse textuelle** est remplie automatiquement (reverse geocoding) mais reste **éditable**

### 4.5 Migration des données existantes
- **R13** : Les appartements existants en cache local Hive **migrent automatiquement** au premier lancement de la nouvelle version :
  - L'adresse de la résidence parente est copiée dans l'appartement
  - Les résidences sont ensuite supprimées du cache local
- **R14** : Migration silencieuse, idempotente (relancer plusieurs fois ne casse rien)
- **R15** : Si un appartement n'a pas de résidence parente trouvable → adresse vide (état brouillon)

### 4.6 Backend
- **R16** : Le **backend Spring Boot n'est pas encore adapté**. Le frontend doit faire une **traduction (mapping)** :
  - À l'envoi : créer/réutiliser une "résidence virtuelle" côté API contenant l'adresse de l'appartement
  - À la réception : aplatir le couple résidence+appartement en un seul appartement avec adresse
- **R17** : Cette couche de traduction est **temporaire** et doit être **isolée** pour pouvoir être supprimée quand le backend sera migré
- **R18** : Une **tâche de suivi backend** doit être créée (TODO documenté) pour aligner Spring Boot ultérieurement

### 4.7 Vue locataire
- **R19** : Le locataire voit une **liste plate d'appartements** (plus de notion de résidence visible)
- **R20** : Les écrans `MesResidences` et `ResidenceDetailScreen` côté locataire sont supprimés
- **R21** : Les filtres existants (prix, ville, équipements…) restent applicables sur la liste plate

## 5. Cas d'Usage Principal — Création d'un appartement

```
Étape 0 : Le proprio est sur "Mes Appartements" (liste de ses biens)
          → Il clique sur le FAB "+"

Étape 1 : Demande de permission GPS (silencieuse si déjà accordée)
          → L'app capte la position actuelle en arrière-plan

Étape 2 : Wizard Airbnb-like — 4 à 5 étapes courtes :
   ┌─────────────────────────────────────────────┐
   │ Étape 1/N : "Où se trouve votre bien ?"     │
   │   - Carte centrée sur position GPS          │
   │   - Pin ajustable                           │
   │   - Adresse textuelle auto-remplie/éditable │
   │                                             │
   │ Étape 2/N : "Décrivez-le brièvement"        │
   │   - Titre (obligatoire)                     │
   │   - Type de location (sélecteur visuel)     │
   │                                             │
   │ Étape 3/N : "Capacité"                      │
   │   - Nb chambres, lits, douches (steppers)   │
   │                                             │
   │ Étape 4/N : "Photos & équipements"          │
   │   - Upload photos (min 3 pour publier)      │
   │   - Équipements (chips/pictos)              │
   │                                             │
   │ Étape 5/N : "Prix & publication"            │
   │   - Prix (devise GHS)                       │
   │   - Récap visuel                            │
   │   - Bouton "Publier"                        │
   └─────────────────────────────────────────────┘

Étape 3 : Auto-save silencieux après chaque étape franchie
          → Si le proprio quitte, son progrès est sauvegardé en brouillon

Étape 4 : Sur l'écran final, validation des règles minimales :
          - Titre, adresse, capacité, prix, ≥3 photos
          → Si OK : bouton "Publier" actif, sinon désactivé avec hint clair

Étape 5 : Publication
          → Envoi backend (avec mapping résidence virtuelle)
          → SnackBar "Votre bien est en ligne 🎉"
          → Retour à "Mes Appartements" avec l'appartement visible en tête
```

## 6. Cas Alternatifs / Limites

### Cas alternatifs
- **CA1 — Reprise de brouillon** : à l'ouverture du wizard, si un brouillon existe en local → modal "Reprendre votre brouillon ?" [Reprendre] / [Repartir de zéro]
- **CA2 — Permission GPS refusée** : on saute l'auto-détection, l'utilisateur place le pin manuellement
- **CA3 — Pas de connexion à la publication** : message clair "Connexion requise pour publier", brouillon conservé
- **CA4 — Modification d'un appartement existant** : même wizard, pré-rempli, étapes navigables librement

### Cas limites
- **CL1 — Migration** : appartement orphelin (sans résidence) → adresse vide, mis en brouillon, notification "Adresse manquante, complétez votre annonce"
- **CL2 — Photos en cours d'upload** : si l'utilisateur quitte → upload stoppé, photos déjà uploadées conservées
- **CL3 — Brouillon trop ancien** : (hors scope V1) — pas d'expiration automatique
- **CL4 — Backend rejette la création** : message d'erreur clair, brouillon conservé pour réessai

## 7. Contraintes

- **C1 — Backend non aligné** : la solution doit fonctionner **sans modification serveur** dans un premier temps, via mapping isolé
- **C2 — Migration sans perte** : aucun bien existant ne doit disparaître ou être inaccessible après mise à jour
- **C3 — Performance** : le wizard doit rester fluide, pas de freeze pendant la géoloc ou l'upload photos
- **C4 — Conformité SOLID** : le nouveau code doit respecter les principes SOLID du projet (séparation des rôles)
- **C5 — Cohérence** : style visuel aligné avec le reste de l'app (palette, widgets existants réutilisés)
- **C6 — Cache Hive** : le cache local actuel (cache-first pattern) doit continuer à fonctionner

## 8. Critères d'Acceptation

### Modèle & migration
- [ ] L'entité `Residence` n'apparaît plus dans le parcours utilisateur (proprio + locataire)
- [ ] L'`Appartement` contient directement son adresse (lat, lng, texte)
- [ ] Les appartements existants en cache sont migrés automatiquement au premier lancement
- [ ] Aucun appartement n'est perdu lors de la migration

### UI Wizard
- [ ] Le formulaire de création est un wizard à étapes courtes (style Airbnb)
- [ ] L'utilisateur peut naviguer librement entre les étapes (avant/arrière)
- [ ] Chaque étape franchie déclenche un auto-save silencieux
- [ ] Le bouton "Publier" est désactivé tant que les minima ne sont pas atteints
- [ ] Un hint clair indique ce qui manque pour publier
- [ ] Au moins **3 photos** sont requises pour publier

### Géolocalisation
- [ ] Permission GPS demandée à l'ouverture du wizard
- [ ] Position auto-détectée pré-remplie sur la carte
- [ ] Pin ajustable manuellement
- [ ] Adresse textuelle auto-remplie (reverse geocoding) et éditable
- [ ] Si permission refusée, le wizard fonctionne en mode manuel

### Brouillon
- [ ] À la fermeture, le brouillon est conservé en local
- [ ] À la réouverture, l'utilisateur peut reprendre ou repartir de zéro
- [ ] Le brouillon n'est jamais envoyé au backend

### Backend & vue locataire
- [ ] La couche de mapping (résidence virtuelle) est isolée dans un service dédié
- [ ] Un TODO documenté pointe la dette technique côté backend
- [ ] Le locataire voit une liste plate d'appartements, sans regroupement

### Qualité
- [ ] Score audit ≥ 60
- [ ] Code conforme SOLID (séparation des rôles)
- [ ] Tests unitaires sur le mapper et la migration

## 9. Hors périmètre (V1)

- 🚫 Modification du backend Spring Boot (tâche séparée à planifier)
- 🚫 Regroupement automatique d'appartements à même adresse (option 4B/4C écartée)
- 🚫 Auto-complétion d'adresse via Google Places (option 7C écartée)
- 🚫 Expiration automatique des brouillons trop anciens
- 🚫 Migration de l'écran Comptabilité (séparé, voir `PLAN_REFACTORING_COMPTABILITE.md`)

---

## 📊 Récap des choix utilisateur

| Question | Réponse | Implication |
|----------|---------|-------------|
| 1. Données existantes | **A** : Migration auto | Script de migration Hive idempotent |
| 2. Backend | **B** : Backend non encore adapté | Mapping côté frontend + TODO backend |
| 3. Vue locataire | **A** : Aussi simplifiée | Suppression écrans Résidence locataire |
| 4. Regroupement | **A** : Aucun (plat) | Modèle simple, pas de logique de groupe |
| 5. Style UI | **A** : Wizard étapes (Airbnb) | UI/UX produit un wizard guidé |
| 6. Brouillon | **C** : Auto-save silencieux | Pas de bouton "Brouillon" visible |
| 7. GPS | **A** : Auto-détection + ajustement | Permission au lancement, pin déplaçable |
| 8. Titre | Obligatoire | Garde la règle existante |
| 9. Photos min | **3** pour publier | Validation côté UI bloque le bouton "Publier" |
