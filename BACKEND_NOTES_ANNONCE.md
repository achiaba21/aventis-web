# 📄 Notes Backend — Système Annonces (Appartements)

> **Date :** 2026-05-12 (refonte `typeLocation` ajoutée le 2026-05-14)
> **Feature liée :** `annonces-refacto` + `typeLocation-enum-refacto`
> **Statut V1 Flutter :** ✅ livré sans dépendance backend bloquante

---

## 0. Type de logement (`typeLocation`) — enum strict — 🚨 COORDINATION REQUISE

### Contexte

Côté Flutter, `Appartement.typeLocation` était une string libre utilisée avec deux sémantiques contradictoires :
- À la création (wizard step 1) : `"Studio" / "2 pièces" / "3 pièces" / "4 pièces" / "5+ pièces"`
- À l'édition : hint suggérant `"Appartement entier / Studio / Chambre privée"` en saisie libre

Refacto livrée le 2026-05-14 : le champ devient un **enum strict 5 valeurs** côté Flutter, et `nbChambres` est désormais **dérivé du type** (sauf pour `CINQ_PLUS` où le proprio le saisit).

### Format JSON attendu

```json
{
  "id": 12,
  "titre": "Loft Plateau",
  "typeLocation": "TROIS_PIECES",   // ← enum strict (5 valeurs possibles)
  "nbChambres": 2
}
```

Valeurs autorisées pour `typeLocation` :
| Valeur | nbChambres dérivé |
|--------|-------------------|
| `STUDIO` | 1 (forcé) |
| `DEUX_PIECES` | 1 (forcé) |
| `TROIS_PIECES` | 2 (forcé) |
| `QUATRE_PIECES` | 3 (forcé) |
| `CINQ_PLUS` | ≥ 4 (saisie libre, min 4) |

### Règle backend à implémenter

Lors du `POST` ou `PUT` d'un Appartement, le backend doit :
1. Refuser un payload où `typeLocation` n'est pas dans `{STUDIO, DEUX_PIECES, TROIS_PIECES, QUATRE_PIECES, CINQ_PLUS}` (HTTP 400).
2. **Forcer** `nbChambres` à la valeur dérivée pour `STUDIO`/`DEUX_PIECES` (= 1), `TROIS_PIECES` (= 2), `QUATRE_PIECES` (= 3).
3. Pour `CINQ_PLUS`, refuser si `nbChambres < 4` (HTTP 400).

### Migration des annonces existantes (one-shot SQL)

Pour chaque ligne en base avec un `typeLocation` legacy en string libre :

**Étape 1 — Matching direct par string (insensible casse) :**
```sql
-- "Studio" → STUDIO + nbChambres = 1
UPDATE appartement
SET type_location = 'STUDIO', nb_chambres = 1
WHERE LOWER(type_location) LIKE '%studio%';

-- "2 pièces", "2p" → DEUX_PIECES + nbChambres = 1
UPDATE appartement
SET type_location = 'DEUX_PIECES', nb_chambres = 1
WHERE LOWER(type_location) ~ '^(2 ?pi.ces|2p)';

-- "3 pièces", "3p" → TROIS_PIECES + nbChambres = 2
UPDATE appartement
SET type_location = 'TROIS_PIECES', nb_chambres = 2
WHERE LOWER(type_location) ~ '^(3 ?pi.ces|3p)';

-- "4 pièces", "4p" → QUATRE_PIECES + nbChambres = 3
UPDATE appartement
SET type_location = 'QUATRE_PIECES', nb_chambres = 3
WHERE LOWER(type_location) ~ '^(4 ?pi.ces|4p)';

-- "5+ pièces", "5+" → CINQ_PLUS + nbChambres conservé si ≥ 4, sinon 4
UPDATE appartement
SET type_location = 'CINQ_PLUS', nb_chambres = GREATEST(COALESCE(nb_chambres, 0), 4)
WHERE LOWER(type_location) ~ '^(5\+|5 ?pi.ces)';
```

**Étape 2 — Pour les autres valeurs legacy (`"Appartement entier"`, `"Chambre privée"`, custom, NULL, vide), dérivation depuis `nbChambres` :**
```sql
UPDATE appartement
SET type_location = CASE
    WHEN nb_chambres >= 4 THEN 'CINQ_PLUS'
    WHEN nb_chambres = 3 THEN 'QUATRE_PIECES'
    WHEN nb_chambres = 2 THEN 'TROIS_PIECES'
    ELSE 'DEUX_PIECES'  -- default safe (cas le plus courant)
  END,
  nb_chambres = CASE
    WHEN nb_chambres >= 4 THEN nb_chambres
    WHEN nb_chambres = 3 THEN 3
    WHEN nb_chambres = 2 THEN 2
    ELSE 1
  END
WHERE type_location NOT IN ('STUDIO', 'DEUX_PIECES', 'TROIS_PIECES', 'QUATRE_PIECES', 'CINQ_PLUS');
```

### Compat descendante côté Flutter (déjà en place)

`AppartementTypeLocation.fromBackend(raw)` accepte les anciennes strings legacy via un fallback `fromLegacy(raw, nbChambres)`. Donc :
- Si le backend déploie cette refacto **avant** Flutter → OK, Flutter sait lire l'enum strict.
- Si le backend déploie **après** Flutter → OK aussi, Flutter sait encore lire les strings libres.

→ Le déploiement peut être désynchronisé sans casse client.

### Priorité

**Haute** — la livraison côté Flutter est faite mais l'app affichera des labels parfois imprécis tant que la migration backend n'est pas faite. Toute nouvelle annonce créée côté Flutter envoie déjà l'enum strict.

---

## 1. Champ `note` exposé directement — 💡 SOUHAITABLE V2

### Contexte
Le modèle `Appartement` côté Flutter a désormais un champ stocké `note: double?` (refacto V1 — suppression du bug `Random()` qui retournait une valeur aléatoire à chaque appel).

### Comportement actuel (V1)
- Si le backend renvoie `note` → champ peuplé direct
- Si le backend ne renvoie pas `note` → fallback côté Flutter : `AppartementDisplay.rating` calcule la moyenne des `commentaires` présents
- Si ni `note` ni `commentaires` → `rating == 0.0` (ou `ratingOrNull == null` pour l'UI)

### Demande backend
Exposer le champ `note: double?` sur le DTO Appartement, calculé par exemple comme :
```sql
SELECT AVG(commentaire.note) FROM commentaire WHERE commentaire.appartement_id = ?
```
ou maintenu par un trigger / event listener à chaque nouveau commentaire.

### Format JSON attendu
```json
{
  "id": 12,
  "titre": "Loft Plateau",
  "note": 4.6,        // ← NOUVEAU
  "commentaires": [...]
}
```

### Pourquoi pas urgent
Le fallback Flutter (`AppartementDisplay.rating`) couvre déjà le cas. Mais une note backend stable :
- Évite de recalculer la moyenne à chaque rendu
- Peut intégrer des pondérations (notes anciennes vs récentes, validation modération…)
- Permet le tri serveur par note (impossible actuellement)

---

## 2. Règle de visibilité unifiée — 🚨 DÉCISION MÉTIER REQUISE

### Constat
3 dimensions de visibilité coexistent sur `Appartement` sans règle métier claire :

| Champ | Valeur | Sémantique actuelle (déduite) |
|-------|--------|-------------------------------|
| `brouillon` | `bool?` | Annonce en cours de création via wizard, pas publiée |
| `isVisible` | `bool?` | Visible dans le feed locataire ? |
| `status` | `AppartementStatus` (`DISPONIBLE` / `OCCUPE` / `EN_MAINTENANCE` / `INACTIF`) | État opérationnel |

### Questions ouvertes
1. Un appart avec `brouillon == false` ET `isVisible == false` ET `status == DISPONIBLE` → visible ?
2. Un appart avec `status == EN_MAINTENANCE` reste-t-il visible aux locataires (mais réservation bloquée) ?
3. Un appart avec `status == OCCUPE` (= déjà réservé) reste-t-il visible (mais réservation bloquée) ?
4. Quel est l'intérêt de distinguer `brouillon` de `isVisible == false` ?

### Recommandation
**Définir une règle métier unique** sous forme de helper côté backend :
```java
public boolean isPublic(Appartement a) {
  return !a.isBrouillon()
      && a.isVisible()
      && a.getStatus() != INACTIF;
}
```
ET la documenter dans le DTO retourné aux locataires (n'envoyer que les appart qui passent le filtre).

Côté Flutter, ce filtre **côté serveur** rend les 3 champs purement informatifs.

### Alternative
Si la complexité actuelle est justifiée :
- **Documenter** explicitement la matrice de visibilité
- **Centraliser** côté Flutter dans une extension `AppartementDisplay.isPublic` avec la même logique

---

## 3. Pagination cursor-based — 💡 V2 SCALABILITÉ

### Problème actuel
`GET auth/appartement/apparts` retourne **tous** les appartements en un seul appel. Si la base atteint 500-1000+ annonces, le feed locataire chargera tout d'un coup → latence importante + bande passante gaspillée.

### Demande backend
Implémenter pagination cursor-based :
```
GET auth/appartement/apparts?cursor=<id>&limit=20
```

Réponse :
```json
{
  "body": [...],
  "nextCursor": 42,
  "hasMore": true
}
```

### Pourquoi cursor-based (pas offset/limit)
- **Stable** sous concurrence (un nouvel appart ajouté n'affecte pas la page suivante)
- **Performant** : index sur `id` plus efficace qu'`OFFSET` qui scanne
- **Standard** moderne (GitHub, Stripe API…)

### Côté Flutter (à prévoir V2)
- `AppartementRepository.getAllAppartements({cursor})`
- Infinite scroll dans `HomeScreen` locataire
- Cache Hive partitionné par page

### Priorité
Faible tant que la base reste < 500 annonces. Devient critique au-delà.

---

## 4. Capacité d'accueil — 💡 V2 SOUHAITABLE

### Contexte
La page `LocataireDetailScreen` et l'onglet `ListingInfosTab` (proprio)
affichent une capacité d'accueil. Aujourd'hui, aucun champ backend ne
représente le nombre maximum de voyageurs.

### Comportement actuel (V1)
- `QuickSpecsCard` affiche **3 colonnes** depuis le backend :
  `nbLits / nbChambres / nbDouches` (vraies valeurs, plus de `beds × 2`).
- L'ancien calcul arbitraire `bedsCount * 2 = travelers` a été **retiré**.
- L'ancienne colonne `surfaceM2` (qui retournait toujours `0`) a été retirée.

### Demande backend
Ajouter 2 colonnes simples sur `Appartement` :

```java
private Integer nbVoyageursMax;  // ex: 4 — capacité d'accueil
private Integer surfaceM2;        // ex: 65 — surface en m²
```

### Format JSON attendu
```json
{
  "id": 12,
  "titre": "Loft Plateau",
  "nbLits": 2,
  "nbChambres": 1,
  "nbDouches": 1,
  "nbVoyageursMax": 4,  // ← NOUVEAU
  "surfaceM2": 65        // ← NOUVEAU
}
```

### Côté Flutter (après migration)
- Ajouter `nbVoyageursMax: int?` + `surfaceM2: int?` dans le modèle
  `Appartement`
- Étendre `QuickSpecsCard` avec 5 colonnes (lits / chambres / sdb /
  voyageurs / m²) — ou garder 3 et ajouter un sous-titre "Jusqu'à X
  voyageurs · X m²" dans `DetailTitleBlock`
- UI éditable côté proprio : étendre `CapacityEditDialog`

### Priorité
**Moyenne** — actuellement les 3 colonnes existantes (lits/chambres/sdb)
suffisent pour informer le locataire honnêtement. Les champs `voyageurs`
et `surface` enrichiraient la fiche mais ne bloquent rien.

---

## 5. Frais de ménage — 💡 V2 SI METIER LE DEMANDE

### Contexte
Le wizard de création (step 5 Prix) affichait jusqu'à la session 2026-05-13
un placeholder visuel "FRAIS DE MÉNAGE (OPTIONNEL)" avec un TextField, sans
aucune persistance (UI menteuse). Le placeholder a été **retiré** côté
Flutter en attendant une décision métier.

### Demande backend (si retenu)
Ajouter un champ optionnel sur `Appartement` :
```java
private Integer fraisMenage;  // ex: 5000 — FCFA, optionnel
```

### Côté Flutter (après migration)
- Ajouter `fraisMenage: int?` dans `Appartement`
- Réafficher le step 5 avec liaison réelle au draft
- Afficher dans `LocataireDetailScreen.PriceDetailCard` (ligne supplémentaire)
- Inclure dans le calcul `_total` du tunnel de réservation

### Priorité
**Faible** — le proprio peut intégrer les frais de ménage dans son prix de
base. À reconsidérer si retour utilisateur demande la séparation.

---

## 6. Commodités normalisées par id — 💡 V2 PROPRETÉ DATA

### Constat
Aujourd'hui le wizard envoie pour les équipements :
```dart
Offre(commodite: Commodite(nom: 'WiFi fibre'))
```
Aucun `id` n'est fourni — c'est une chaîne libre. Selon la politique du
backend, ça peut créer :
- Des **doublons** si plusieurs proprios saisissent différemment ("WiFi",
  "Wifi", "WIFI", "Wifi fibre")
- Une **dépendance fragile** : si le backend renomme "WiFi" → "Internet
  haut débit", les références existantes pointent dans le vide

### Demande backend
Exposer un endpoint dictionnaire :
```
GET /api/commodites
→ [
    { "id": 1, "nom": "WiFi", "iconCode": "wifi" },
    { "id": 2, "nom": "Clim", "iconCode": "ac_unit" },
    ...
  ]
```

### Côté Flutter (après migration)
- Picker `StepAmenities` charge la liste backend au build
- Toggle envoie `Offre(commodite: Commodite(id: 1))` (avec id, pas nom)
- Cohérence garantie + risque doublons éliminé

### Priorité
**Moyenne** — pas bloquant tant que la base reste petite et qu'un admin
nettoie les doublons régulièrement.

---

## 7. Règles structurées — ✅ V1 ALIGNÉ

### Contexte historique
Jusqu'à la session 2026-05-13, le wizard sérialisait les toggles
(Démarcheurs/Caution/Animaux) dans une chaîne technique stockée dans
`Appartement.regles` :
```
"demarcheurs=true;caution=true;animaux=false"
```
Pendant ce temps, la collection structurée `appartementRules: List<AppartementRule>`
côté backend (avec `iconName/text/isAllowed`) n'était **jamais remplie**.

### V1 livrée
Le wizard remplit désormais `appart.rules` (mappé sur `appartementRules`
backend) avec une `List<Rule>` typée :
```dart
[
  Rule(iconName: 'handshake', text: 'Démarcheurs acceptés', isAllowed: true),
  Rule(iconName: 'shield',    text: 'Caution remboursable', isAllowed: true),
  Rule(iconName: 'pets',      text: 'Animaux',              isAllowed: false),
]
```
Le champ `regles` (texte libre) reste vide à la création — le proprio
pourra l'éditer ensuite via `ListingRulesTab` pour ajouter des règles
custom non couvertes par les toggles.

### V2 amélioration possible
Si le backend veut exposer un dictionnaire de "règles types" (comme pour
les commodités, cf. §6), passer à un système d'`id` plutôt que des
chaînes `iconName/text` libres.

---

## 8. Récapitulatif

| Demande | Priorité | Statut |
|---------|----------|--------|
| `typeLocation` enum strict + migration | **Haute** | ⏳ Coordination 2026-05-14 (compat Flutter assurée) |
| Champ `note` exposé direct | Moyenne | V2 (fallback Flutter en place) |
| Règle de visibilité unifiée | Haute | ⏳ Décision métier requise |
| Pagination cursor-based | Faible | V2 quand >500 annonces |
| `nbVoyageursMax` + `surfaceM2` | Moyenne | V2 (3 colonnes honnêtes en V1) |
| Champ `fraisMenage` | Faible | À décider métier |
| `GET /api/commodites` (id-based) | Moyenne | V2 propreté data |
| Règles structurées `appartementRules` | ✅ V1 | Wizard livre la collection 2026-05-13 |
| Suppression `AppartementBackendMapper` legacy | ✅ V1 | Mapper simplifié 2026-05-13 (payload flat) |
