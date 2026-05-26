# 📋 Spécification Métier — `typeLocation-enum-refacto`

> **Date :** 2026-05-14
> **Validée par :** utilisateur (oui — v2 corrigée)
> **Mode workflow :** `/feature full`

---

## 1. Contexte

Le champ `Appartement.typeLocation` (string libre) est utilisé aujourd'hui avec deux sémantiques contradictoires :

- À la **création** (wizard step 1) : il reçoit `"Studio" / "2 pièces" / "3 pièces" / "4 pièces" / "5+ pièces"` (= typologie de pièces).
- À l'**édition** (`ListingInfosTab._editType`) : son hint propose `"Appartement entier / Studio / Chambre privée"` (= autre vocabulaire) en saisie libre.

Le wizard demande deux fois la même info : le type au step 1 implique déjà le nombre de chambres, puis le step 2 redemande `nbChambres` en saisie libre — sans aucune cohérence croisée. Un `Studio` + `nbChambres = 5` est publiable aujourd'hui.

## 2. Objectif

Faire de `typeLocation` la **source de vérité unique** de la typologie de pièces, sous forme d'un **enum strict à 5 valeurs**. Le nombre de chambres devient une donnée **dérivée du type**, sauf pour le cas "5+ pièces" qui reste libre. Le double-input disparaît, le champ d'édition libre est remplacé par un picker enum.

## 3. Acteurs

- **Proprio** (création + édition d'annonce) — acteur principal.
- **Locataire** (lecture sur fiche détail) — acteur secondaire, pas de changement comportemental.
- **Équipe backend** — pour la normalisation enum + migration des valeurs existantes.

## 4. Règles Métier

### 4.1 Type de logement (enum strict — aligné sur l'UI existante)

| Valeur enum | Libellé | Sémantique métier | nbChambres dérivé |
|-------------|---------|--------------------|-------------------|
| `STUDIO` | Studio | Pièce unique qui sert à la fois de chambre et de salon. Pas de salon séparé. | **1** (forcé) |
| `DEUX_PIECES` | 2 pièces | 1 salon + 1 chambre fermée. | **1** (forcé) |
| `TROIS_PIECES` | 3 pièces | 1 salon + 2 chambres. | **2** (forcé) |
| `QUATRE_PIECES` | 4 pièces | 1 salon + 3 chambres. | **3** (forcé) |
| `CINQ_PLUS` | 5+ pièces | 1 salon + 4 chambres minimum. Saisie libre pour le nombre exact. | **≥ 4** (saisi par le proprio) |

> Convention : le salon n'est pas stocké comme champ. Sa présence est implicite (`STUDIO` = sans salon, tous les autres = avec salon).

### 4.2 Dérivation `nbChambres` (règle stricte)

Le champ `nbChambres` est **automatiquement déterminé par `typeLocation`** dans 4 cas sur 5 :

```
typeLocation = STUDIO        → nbChambres = 1 (figé)
typeLocation = DEUX_PIECES   → nbChambres = 1 (figé)
typeLocation = TROIS_PIECES  → nbChambres = 2 (figé)
typeLocation = QUATRE_PIECES → nbChambres = 3 (figé)
typeLocation = CINQ_PLUS     → nbChambres saisi par le proprio (min 4, max 10)
```

Quand le type change, `nbChambres` est **recalculé immédiatement** :
- Bascule vers `STUDIO`/`2P`/`3P`/`4P` → `nbChambres` est forcé à la valeur dérivée.
- Bascule vers `CINQ_PLUS` → `nbChambres` est forcé à 4 (default minimum), le proprio peut ajuster ensuite.

### 4.3 Comportement wizard

**Step 1 (`StepRoomsType` actuel)** : aucun changement visuel — la grille 2 colonnes avec 5 cards (Studio, 2 pièces, 3 pièces, 4 pièces, 5+ pièces) reste à l'identique. Seule la valeur stockée change : enum strict au lieu de string libre.

**Step 2 (capacité)** :
- Si `typeLocation ∈ {STUDIO, 2P, 3P, 4P}` → le **stepper "Chambres" est masqué** (valeur dérivée et figée). La Row devient `[Lits] [SdB]` en 2 colonnes.
- Si `typeLocation = CINQ_PLUS` → le stepper Chambres redevient visible avec `min = 4, max = 10`. La Row redevient `[Lits] [Chambres] [SdB]` en 3 colonnes.
- `Lits` et `SdB` restent toujours visibles et libres.

### 4.4 Validator de publication

Le `AppartementPublicationValidator` doit refuser la publication si :

- `typeLocation` est `null`.
- `nbChambres < 1` (peu importe le type).
- `typeLocation ∈ {STUDIO, 2P}` et `nbChambres != 1`.
- `typeLocation = 3P` et `nbChambres != 2`.
- `typeLocation = 4P` et `nbChambres != 3`.
- `typeLocation = CINQ_PLUS` et `nbChambres < 4`.

### 4.5 Édition post-publication

Le proprio peut **librement** changer le type via un picker enum (5 options). Quand il valide un nouveau type :
- Si le nouveau type a `nbChambres` dérivé fixe (STUDIO/2P/3P/4P) → `nbChambres` est **automatiquement ajusté** à la valeur dérivée au save.
- Si le nouveau type est `CINQ_PLUS` et l'ancien `nbChambres < 4` → `nbChambres` est forcé à 4 ; le proprio peut ensuite ajuster via le dialog "Capacité" existant.
- Un toast informe le proprio quand un ajustement automatique a lieu (« Type changé en *X*, nombre de chambres ajusté à *N* »).

Aucune restriction liée aux réservations actives.

### 4.6 Migration backend (coord équipe backend)

Mapping automatique des `typeLocation` existants (chaînes libres) côté backend lors de la migration, combinant la string legacy + le `nbChambres` actuel :

**Étape 1 — Matching direct par string (insensible casse) :**
- `"Studio"` → `STUDIO`, `nbChambres` forcé à 1
- `"2 pièces"`, `"2p"` → `DEUX_PIECES`, `nbChambres` forcé à 1
- `"3 pièces"`, `"3p"` → `TROIS_PIECES`, `nbChambres` forcé à 2
- `"4 pièces"`, `"4p"` → `QUATRE_PIECES`, `nbChambres` forcé à 3
- `"5+ pièces"`, `"5+"`, `"5 pièces et +"` → `CINQ_PLUS`, `nbChambres` conservé si ≥ 4, sinon forcé à 4

**Étape 2 — Pour les autres valeurs legacy (`"Appartement entier"`, `"Chambre privée"`, valeurs custom, `null`, vide) :** dérivation depuis `nbChambres` :
- `nbChambres = 0` ou `nbChambres = 1` → `DEUX_PIECES` par défaut (cas le plus courant) + force `nbChambres = 1`
- `nbChambres = 2` → `TROIS_PIECES`, force `nbChambres = 2`
- `nbChambres = 3` → `QUATRE_PIECES`, force `nbChambres = 3`
- `nbChambres ≥ 4` → `CINQ_PLUS`, `nbChambres` conservé
- `nbChambres = null` → `DEUX_PIECES` par défaut + `nbChambres = 1`

### 4.7 Champs hors scope (inchangés)

- `nbLits` : saisie libre par le proprio, sans contrainte.
- `nbDouches` : saisie libre par le proprio, sans contrainte.
- Aucun champ `nbSalon` introduit (info implicite dans l'enum).

## 5. Cas d'Usage Principal — Création d'annonce

1. Proprio tape sur "+" → wizard ouvre.
2. **Step 1** : grille 2 colonnes (5 cards Studio / 2P / 3P / 4P / 5+). Une seule sélection. → typeLocation enum.
3. **Step 2** : (changement majeur)
   - Si typeLocation ∈ {Studio, 2P, 3P, 4P} → Row à 2 colonnes : `[Lits −/+] [SdB −/+]`. Chambres masqué (dérivé).
   - Si typeLocation = 5+ → Row à 3 colonnes : `[Lits −/+] [Chambres −/+ (min 4)] [SdB −/+]`.
4. Steps 3 (photos), 4 (commodités), 5 (prix) inchangés.
5. Publication → validator vérifie cohérence type ↔ chambres → API.

## 6. Cas d'Usage — Édition

1. Proprio ouvre `ListingInfosTab`, tape sur la FieldRow `TYPE`.
2. Picker enum s'ouvre (5 options dans un Dialog).
3. Proprio sélectionne un nouveau type.
4. Au save : `nbChambres` automatiquement ajusté si nécessaire ; toast confirme l'ajustement.
5. La fiche affiche le nouveau type + nouvelle capacité.

## 7. Cas Alternatifs / Limites

- **Bascule de 5+ pièces vers Studio en édition** : `nbChambres` passe de 6 (par ex.) à 1. Toast : « Type changé en Studio, nombre de chambres ajusté à 1. »
- **Draft Hive contenant un ancien `typeLocation` string libre** : à la reprise du draft, on tente le mapping de la §4.6 ; default safe `DEUX_PIECES` si non identifiable.
- **Backend renvoie une valeur enum inconnue** (forward-compat) : Flutter parse comme `DEUX_PIECES` (default safe) et log un debug warning.
- **Cas legacy de la base avec `typeLocation = null` ET `nbChambres = null`** : mappé à `DEUX_PIECES` + `nbChambres = 1`.

## 8. Contraintes

- **Pas de nouveau filtre locataire** dans cette feature.
- **Coordination backend obligatoire** : migration + exposition de l'enum doivent être livrées en même temps que le client.
- **Compatibilité descendante** : pendant la fenêtre de déploiement, le client doit tolérer une string libre côté `typeLocation` → applique le mapping §4.6.
- **UI inchangée** : design system, layout, couleurs, cards style — tout reste comme aujourd'hui. Seule la suppression conditionnelle du stepper Chambres (step 2) et le remplacement du `TextFieldEditDialog` par un picker enum (édition) sont visibles.

## 9. Critères d'Acceptation

- [ ] Un proprio ne peut **pas** publier un Studio/2P avec `nbChambres ≠ 1`, ni un 3P avec `nbChambres ≠ 2`, ni un 4P avec `nbChambres ≠ 3`, ni un 5+ avec `nbChambres < 4`.
- [ ] Le step 1 garde son design actuel (grille 2 cols, 5 cards) à l'identique visuellement.
- [ ] Le stepper Chambres est masqué au step 2 pour Studio/2P/3P/4P, visible pour 5+.
- [ ] Le picker enum d'édition remplace la saisie libre de texte.
- [ ] Quand le type est édité, `nbChambres` est automatiquement ajusté ; un toast informe le proprio en cas de changement.
- [ ] Les annonces existantes sont mappées correctement (à valider sur staging selon §4.6).
- [ ] Les drafts Hive existants (encore avec `typeLocation` string libre) ne plantent pas à la reprise.
- [ ] La fiche détail locataire affiche le libellé (« Studio », « 2 pièces »…) lisiblement.
- [ ] Aucun nouveau filtre n'est ajouté côté locataire.
