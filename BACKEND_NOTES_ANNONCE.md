# 📄 Notes Backend — Système Annonces (Appartements)

> **Date :** 2026-05-12
> **Feature liée :** `annonces-refacto`
> **Statut V1 Flutter :** ✅ livré sans dépendance backend bloquante

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

## 5. Récapitulatif

| Demande | Priorité | Statut |
|---------|----------|--------|
| Champ `note` exposé direct | Moyenne | V2 (fallback Flutter en place) |
| Règle de visibilité unifiée | Haute | ⏳ Décision métier requise |
| Pagination cursor-based | Faible | V2 quand >500 annonces |
| `nbVoyageursMax` + `surfaceM2` | Moyenne | V2 (3 colonnes honnêtes en V1) |
| Suppression `AppartementBackendMapper` (legacy) | Bloquant V2 | ⏳ Migration `BACKEND-FLAT-APPART` à mener |
